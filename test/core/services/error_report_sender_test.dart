import 'dart:async';
import 'dart:io';
import 'package:control_financiero/core/services/error_report_sender.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late File file;
  const id = '1791530000000000';
  const endpoint = 'https://reports.example.com/reports';
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('report_send_test_');
    file = await File(
      '${directory.path}/reporte_error_$id.zip',
    ).writeAsBytes([0x50, 0x4b, 3, 4]);
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('sends ZIP and report ID only to configured HTTPS endpoint', () async {
    final sender = ErrorReportSender(
      endpoint: endpoint,
      upload: (url, archive, reportId) async {
        expect(url.toString(), endpoint);
        expect(archive.path, file.path);
        expect(reportId, id);
        return const ReportUploadResponse(
          202,
          '{"status":"accepted","report_id":"$id"}',
        );
      },
    );
    await sender.send(file);
  });

  test('unset or unsafe endpoints never upload', () async {
    var calls = 0;
    for (final url in [
      '',
      'http://reports.example.com/reports',
      'https://key@reports.example.com/reports',
      'https://reports.example.com/other',
      'https://reports.example.com/reports?key=secret',
    ]) {
      final sender = ErrorReportSender(
        endpoint: url,
        upload: (_, _, _) async {
          calls++;
          return const ReportUploadResponse(202, '{}');
        },
      );
      await expectLater(sender.send(file), throwsA(isA<ReportSendException>()));
    }
    expect(calls, 0);
  });

  test(
    'rejects oversized files and invalid report filenames before uploading',
    () async {
      var calls = 0;
      final sender = ErrorReportSender(
        endpoint: endpoint,
        upload: (_, _, _) async {
          calls++;
          return const ReportUploadResponse(202, '{}');
        },
      );
      final randomFile = await File(
        '${directory.path}/backup.zip',
      ).writeAsString('data');
      await expectLater(
        sender.send(randomFile),
        throwsA(isA<ReportSendException>()),
      );
      final handle = await file.open(mode: FileMode.write);
      await handle.truncate(ErrorReportSender.maxBytes + 1);
      await handle.close();
      await expectLater(sender.send(file), throwsA(isA<ReportSendException>()));
      expect(calls, 0);
    },
  );

  test(
    'rate limit, provider failure and unexpected success never claim acceptance',
    () async {
      for (final response in [
        const ReportUploadResponse(429, '{}'),
        const ReportUploadResponse(502, '{}'),
        const ReportUploadResponse(200, '{}'),
        const ReportUploadResponse(202, '{}'),
        const ReportUploadResponse(
          202,
          '{"status":"accepted","report_id":"wrong"}',
        ),
        const ReportUploadResponse(202, 'invalid JSON'),
      ]) {
        final sender = ErrorReportSender(
          endpoint: endpoint,
          upload: (_, _, _) async => response,
        );
        await expectLater(
          sender.send(file),
          throwsA(isA<ReportSendException>()),
        );
      }
    },
  );

  test(
    'connection failure and timeout return actionable messages without raw details',
    () async {
      for (final error in [
        const SocketException('private host or token'),
        TimeoutException('secret'),
      ]) {
        final sender = ErrorReportSender(
          endpoint: endpoint,
          upload: (_, _, _) async => throw error,
        );
        await expectLater(
          sender.send(file),
          throwsA(
            isA<ReportSendException>().having(
              (e) => e.message,
              'message',
              allOf(isNot(contains('secret')), isNot(contains('private'))),
            ),
          ),
        );
      }
    },
  );
}
