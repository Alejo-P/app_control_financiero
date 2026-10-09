import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:control_financiero/core/services/error_report_service.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  final now = DateTime.utc(2026, 10, 9);
  setUp(() async {
    root = await Directory.systemTemp.createTemp('diagnostics_test_');
  });
  tearDown(() async {
    await root.delete(recursive: true);
  });

  test('trace keeps package and Dart frames without local user paths', () {
    final trace = AppLogger.diagnosticStack(
      StackTrace.fromString(
        '#0 save (file:///Users/Personal/secret.dart:12:3)\n'
        '#1 save (package:control_financiero/save.dart:20:1)\n'
        '#2 run (dart:async/zone.dart:12:1)\n',
      ),
    );
    expect(trace, contains('package:control_financiero/save.dart'));
    expect(trace, contains('dart:async/zone.dart'));
    expect(trace, isNot(contains('Personal')));
    expect(trace, isNot(contains('secret')));
  });

  test(
    'serializes concurrent writes and snapshot without losing entries',
    () async {
      final store = DiagnosticLogStore(Directory('${root.path}/logs'));
      final writes = List.generate(30, (i) => store.write('event $i\n', now));
      final snapshot = store.snapshot(now);
      await Future.wait(writes);
      final logs = await snapshot;
      expect(logs.length, 1);
      final lines = logs.values.single.trim().split('\n');
      expect(lines.length, 30);
      expect(lines.first, 'event 0');
      expect(lines.last, 'event 29');
    },
  );

  test('rotates by bytes and retains the two latest segments', () async {
    final store = DiagnosticLogStore(root, maxBytes: 9);
    for (final event in ['uno\n', 'dos\n', 'tres\n', 'fin\n', 'más\n']) {
      await store.write(event, now);
    }
    final logs = await store.snapshot(now);
    expect(logs.length, 2);
    expect(logs['app_log_2026-10-09.log'], 'más\n');
    expect(logs['app_log_2026-10-09.log.previous'], 'tres\nfin\n');
    for (final value in logs.values) {
      expect(utf8.encode(value).length, lessThanOrEqualTo(9));
    }
  });

  test(
    'retains seven UTC dates and excludes unrelated and old files',
    () async {
      final store = DiagnosticLogStore(root);
      await store.write('old', now.subtract(const Duration(days: 7)));
      await store.write('boundary', now.subtract(const Duration(days: 6)));
      await File('${root.path}/backup.json').writeAsString('private data');
      await File(
        '${root.path}/app_log_old_timestamp.log',
      ).writeAsString('old private logs');
      await store.write('current', now);
      final logs = await store.snapshot(now);
      expect(
        logs.keys,
        containsAll(['app_log_2026-10-03.log', 'app_log_2026-10-09.log']),
      );
      expect(logs.length, 2);
      expect(
        await File('${root.path}/app_log_2026-10-02.log').exists(),
        isFalse,
      );
      expect(await File('${root.path}/backup.json').exists(), isTrue);
    },
  );

  test('failed write does not poison later writes or recurse', () async {
    final obstacle = File('${root.path}/blocked');
    await obstacle.writeAsString('obstacle');
    final store = DiagnosticLogStore(Directory(obstacle.path));
    await expectLater(
      store.write('first', now),
      throwsA(isA<FileSystemException>()),
    );
    await obstacle.delete();
    await store.write('recovered', now);
    expect((await store.snapshot(now)).values.single, 'recovered');
  });

  test(
    'ZIP includes metadata, description and logs without neighboring files',
    () async {
      await File('${root.path}/financial.db').writeAsString('sensitive');
      final service = ErrorReportService(
        metadata: () async => {
          'app': {'version': '1.0.0', 'build': '13'},
          'device': {'model': 'test'},
        },
        logs: () async => {
          'app_log_2026-10-09.log': 'event\npackage:app/test.dart:1\n',
        },
        outputDirectory: () async => root,
      );
      final file = await service.createReport(' Falló al guardar ');
      final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
      final names = archive.files.map((f) => f.name).toList();
      expect(
        names,
        containsAll([
          'device_info.json',
          'description.txt',
          'README.txt',
          'logs/app_log_2026-10-09.log',
        ]),
      );
      expect(names, isNot(contains('financial.db')));
      String read(String name) =>
          utf8.decode(archive.findFile(name)!.content as List<int>);
      expect(read('description.txt'), 'Falló al guardar');
      final metadata =
          jsonDecode(read('device_info.json')) as Map<String, dynamic>;
      expect(metadata['app']['build'], '13');
      expect(metadata['device']['model'], 'test');
      expect(metadata['report_id'], isNotEmpty);
    },
  );

  test('report works without logs and marks unavailable logs', () async {
    final service = ErrorReportService(
      metadata: () async => {},
      logs: () async => throw const FileSystemException('unreadable'),
      outputDirectory: () async => root,
    );
    final file = await service.createReport('');
    final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
    expect(archive.findFile('logs/empty.txt'), isNotNull);
    final metadata = jsonDecode(
      utf8.decode(archive.findFile('device_info.json')!.content as List<int>),
    );
    expect(metadata['logs_status'], 'unavailable');
  });

  test(
    'report cleans old generated ZIPs and preserves unrelated files',
    () async {
      final old = await File(
        '${root.path}/reporte_error_1.zip',
      ).writeAsString('old');
      await old.setLastModified(
        DateTime.now().subtract(const Duration(days: 2)),
      );
      final other = await File('${root.path}/other.zip').writeAsString('keep');
      final service = ErrorReportService(
        metadata: () async => {},
        logs: () async => {},
        outputDirectory: () async => root,
      );
      await service.createReport('');
      expect(await old.exists(), isFalse);
      expect(await other.exists(), isTrue);
    },
  );
}
