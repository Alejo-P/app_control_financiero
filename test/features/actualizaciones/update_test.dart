import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:control_financiero/features/actualizaciones/update_controller.dart';
import 'package:control_financiero/features/actualizaciones/update_dialog.dart';
import 'package:control_financiero/features/actualizaciones/update_release.dart';
import 'package:control_financiero/features/actualizaciones/update_service.dart';
import 'package:control_financiero/core/theme/app_theme.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

final payload = List<int>.generate(4096, (i) => i % 256);
UpdateRelease release({String? hash}) => UpdateRelease(
  version: '1.1.3',
  buildNumber: 17,
  notes: 'Mejoras de recordatorios',
  url: Uri.parse(
    'https://github.com/${UpdateService.repository}/releases/download/v1.1.3/mi-presupuesto-v1.1.3.apk',
  ),
  size: payload.length,
  sha256: hash ?? sha256.convert(payload).toString(),
);

class RealHttp extends HttpOverrides {}

class LocalService extends UpdateService {
  LocalService(this.server, Directory directory)
    : super(
        apiEndpoint: Uri.parse('http://localhost:${server.port}/latest'),
        temporaryDirectory: () async => directory,
        clientFactory: () => RealHttp().createHttpClient(null),
        packageInfo: () async => PackageInfo(
          appName: 'test',
          packageName: 'com.example.control_financiero',
          version: '1.1.2',
          buildNumber: '16',
        ),
      );
  final HttpServer server;
  @override
  Uri assetUrl(dynamic value) => Uri.parse(
    'http://localhost:${server.port}/${value.toString().endsWith('update.json') ? 'manifest' : 'apk'}',
  );
}

class FakeService extends UpdateService {
  bool permitted = false;
  int settings = 0;
  int installs = 0;
  UpdateCancellation? downloadToken;
  final completion = Completer<File>();
  @override
  Future<UpdateRelease?> check(UpdateCancellation cancellation) async =>
      release();
  @override
  Future<File> download(
    UpdateRelease release,
    UpdateCancellation cancellation,
    void Function(DownloadProgress) onProgress,
  ) {
    downloadToken = cancellation;
    onProgress(DownloadProgress(1024, payload.length, 1024));
    return completion.future;
  }

  @override
  Future<bool> canInstall() async => permitted;
  @override
  Future<void> requestInstallPermission() async {
    settings++;
  }

  @override
  Future<void> install(File file, UpdateRelease release) async {
    installs++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'version comparison uses numbers and rejects unstable/malformed tags',
    () {
      expect(compareVersions('v1.1.10', '1.1.9'), greaterThan(0));
      expect(compareVersions('1.1.2', '1.1.2'), 0);
      expect(compareVersions('1.1.1', '1.1.2'), lessThan(0));
      expect(
        () => compareVersions('v1.2.0-beta', '1.1.2'),
        throwsA(isA<UpdateException>()),
      );
    },
  );

  test('manifest binds version, build, file, size and hash to release', () {
    final json = {
      'version': '1.1.3',
      'buildNumber': 17,
      'file': 'mi-presupuesto-v1.1.3.apk',
      'size': payload.length,
      'sha256': sha256.convert(payload).toString(),
    };
    UpdateRelease parse(Map<String, dynamic> data) =>
        UpdateRelease.fromManifest(
          data,
          tag: 'v1.1.3',
          notes: '',
          url: release().url,
          assetName: 'mi-presupuesto-v1.1.3.apk',
          assetSize: payload.length,
        );
    expect(parse(json).buildNumber, 17);
    for (final entry in {
      'version': '1.1.4',
      'buildNumber': 0,
      'size': 1,
      'file': 'other.apk',
      'sha256': 'invalid',
    }.entries) {
      expect(
        () => parse({...json, entry.key: entry.value}),
        throwsA(isA<UpdateException>()),
      );
    }
  });

  test('production asset links are restricted to this repository over HTTPS', () {
    final service = UpdateService();
    expect(service.assetUrl(release().url.toString()), release().url);
    for (final url in [
      'http://github.com/${UpdateService.repository}/releases/download/x/a.apk',
      'https://evil.example/a.apk',
      'https://github.com/other/repo/releases/download/x/a.apk',
    ]) {
      expect(() => service.assetUrl(url), throwsA(isA<UpdateException>()));
    }
  });

  group('real HTTP download and cleanup', () {
    late Directory directory;
    late HttpServer server;
    late LocalService service;
    var verified = 0;
    setUp(() async {
      directory = await Directory.systemTemp.createTemp('update_test_');
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      service = LocalService(server, directory);
      verified = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(UpdateService.channel, (call) async {
            if (call.method == 'verify') verified++;
            return null;
          });
    });
    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(UpdateService.channel, null);
      await server.close(force: true);
      await directory.delete(recursive: true);
    });
    void servePayload() {
      server.listen((request) async {
        request.response.contentLength = payload.length;
        request.response.add(payload);
        await request.response.close();
      });
    }

    test(
      'valid download reports progress and verifies before becoming ready',
      () async {
        servePayload();
        final progress = <DownloadProgress>[];
        final file = await service.download(
          release(),
          UpdateCancellation(),
          progress.add,
        );
        expect(await file.readAsBytes(), payload);
        expect(file.path.endsWith('.apk'), isTrue);
        expect(verified, 1);
        expect(progress.last.fraction, 1);
        await service.cleanDownloads();
        expect(await file.exists(), isFalse);
      },
    );

    test(
      'bad hash deletes partial APK and never invokes native verification',
      () async {
        servePayload();
        await expectLater(
          service.download(
            release(hash: '0' * 64),
            UpdateCancellation(),
            (_) {},
          ),
          throwsA(isA<UpdateException>()),
        );
        expect(verified, 0);
        expect(
          await Directory('${directory.path}/app_updates').list().toList(),
          isEmpty,
        );
      },
    );

    test('cancelling an active stream deletes partial APK', () async {
      server.listen((request) async {
        request.response.contentLength = payload.length;
        request.response.add(payload.take(1024).toList());
        try {
          await request.response.flush();
        } catch (_) {}
      });
      final token = UpdateCancellation();
      final future = service.download(release(), token, (_) => token.cancel());
      // First progress can be suppressed by throttling; abort after the file exists.
      Timer(const Duration(milliseconds: 350), token.cancel);
      await expectLater(future, throwsA(anything));
      expect(verified, 0);
      expect(
        await Directory('${directory.path}/app_updates').list().toList(),
        isEmpty,
      );
    });

    test(
      'wrong content length is rejected before native verification',
      () async {
        server.listen((request) async {
          request.response.add([1, 2, 3]);
          await request.response.close();
        });
        await expectLater(
          service.download(release(), UpdateCancellation(), (_) {}),
          throwsA(isA<UpdateException>()),
        );
        expect(verified, 0);
        expect(
          await Directory('${directory.path}/app_updates').list().toList(),
          isEmpty,
        );
      },
    );

    test('native package rejection removes the downloaded APK', () async {
      servePayload();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(UpdateService.channel, (_) async {
            throw PlatformException(
              code: 'INVALID_APK',
              message: 'Firma incorrecta',
            );
          });
      await expectLater(
        service.download(release(), UpdateCancellation(), (_) {}),
        throwsA(isA<PlatformException>()),
      );
      expect(
        await Directory('${directory.path}/app_updates').list().toList(),
        isEmpty,
      );
    });

    test('startup cleanup removes APKs left by a killed process', () async {
      final cache = await Directory('${directory.path}/app_updates').create();
      await File('${cache.path}/update-1.apk.part').writeAsBytes([1]);
      await File('${cache.path}/update-2.apk').writeAsBytes([2]);
      await service.cleanDownloads();
      expect(await cache.list().toList(), isEmpty);
    });

    for (final tag in ['v1.1.2', 'v1.1.1']) {
      test('installed version is not offered release $tag', () async {
        server.listen((request) async {
          request.response.write(
            jsonEncode({
              'draft': false,
              'prerelease': false,
              'tag_name': tag,
              'assets': [],
            }),
          );
          await request.response.close();
        });
        expect(await service.check(UpdateCancellation()), isNull);
      });
    }

    test('draft and prerelease responses cannot be installed', () async {
      server.listen((request) async {
        request.response.write(
          jsonEncode({
            'draft': false,
            'prerelease': true,
            'tag_name': 'v1.1.3',
            'assets': [],
          }),
        );
        await request.response.close();
      });
      await expectLater(
        service.check(UpdateCancellation()),
        throwsA(isA<UpdateException>()),
      );
    });

    test('published release and manifest produce a newer build', () async {
      server.listen((request) async {
        request.response.headers.contentType = ContentType.json;
        final base =
            'https://github.com/${UpdateService.repository}/releases/download/v1.1.3/';
        request.response.write(
          jsonEncode(
            request.uri.path == '/latest'
                ? {
                    'draft': false,
                    'prerelease': false,
                    'tag_name': 'v1.1.3',
                    'body': 'Novedades',
                    'assets': [
                      {
                        'name': 'mi-presupuesto-v1.1.3.apk',
                        'size': payload.length,
                        'browser_download_url':
                            '${base}mi-presupuesto-v1.1.3.apk',
                      },
                      {
                        'name': 'update.json',
                        'browser_download_url': '${base}update.json',
                      },
                    ],
                  }
                : {
                    'version': '1.1.3',
                    'buildNumber': 17,
                    'size': payload.length,
                    'file': 'mi-presupuesto-v1.1.3.apk',
                    'sha256': sha256.convert(payload).toString(),
                  },
          ),
        );
        await request.response.close();
      });
      expect((await service.check(UpdateCancellation()))!.buildNumber, 17);
    });

    test('404 is an unavailable public release, not up to date', () async {
      server.listen((request) async {
        request.response.statusCode = 404;
        await request.response.close();
      });
      await expectLater(
        service.check(UpdateCancellation()),
        throwsA(isA<UpdateException>()),
      );
    });
  });

  test(
    'leaving foreground cancels and late completion cannot restore ready state',
    () async {
      final service = FakeService();
      final controller = UpdateController(service);
      await controller.check();
      final download = controller.download();
      controller.leaveForeground();
      expect(service.downloadToken!.cancelled, isTrue);
      final directory = await Directory.systemTemp.createTemp('late_update_');
      final file = await File(
        '${directory.path}/update.apk',
      ).writeAsBytes(payload);
      service.completion.complete(file);
      await download;
      expect(controller.phase, UpdatePhase.cancelled);
      expect(await file.exists(), isFalse);
      controller.dispose();
      await directory.delete();
    },
  );

  test(
    'permission denial never loops settings and granting resumes installation',
    () async {
      final service = FakeService();
      final controller = UpdateController(service);
      await controller.check();
      final download = controller.download();
      service.completion.complete(File('verified.apk'));
      await download;
      await controller.install();
      expect(service.settings, 1);
      controller.leaveForeground();
      expect(controller.phase, UpdatePhase.ready);
      await controller.resume();
      expect(service.settings, 1);
      expect(service.installs, 0);
      await controller.install();
      service.permitted = true;
      await controller.resume();
      expect(service.installs, 1);
      controller.dispose();
    },
  );

  testWidgets('download notice fits narrow screens and lifecycle cancels', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = FakeService();
    final controller = UpdateController(service);
    await controller.check();
    unawaited(controller.download());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: UpdateDialog(controller: controller),
      ),
    );
    await tester.pump();
    expect(find.textContaining('Permanezca en esta vista'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(service.downloadToken!.cancelled, isTrue);
    expect(find.text('Descarga cancelada'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    service.completion.completeError(const UpdateException('Cancelada'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
  });
}
