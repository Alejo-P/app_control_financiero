import 'dart:io';

import 'package:path/path.dart' as p;

class BackupFileWriter {
  static Future<File> write(
    String directory,
    String content, {
    DateTime? createdAt,
  }) async {
    final date = createdAt ?? DateTime.now();
    final timestamp = [
      date.year.toString().padLeft(4, '0'),
      ...[
        date.month,
        date.day,
        date.hour,
        date.minute,
        date.second,
      ].map((value) => value.toString().padLeft(2, '0')),
    ].join('_');

    for (var suffix = 0; ; suffix++) {
      final name = 'backup_$timestamp${suffix == 0 ? '' : '_$suffix'}.json';
      final file = File(p.join(directory, name));
      try {
        // Reserve the name atomically, including concurrent backup requests.
        await file.create(exclusive: true);
      } on FileSystemException {
        if (await FileSystemEntity.type(file.path, followLinks: false) !=
            FileSystemEntityType.notFound) {
          continue;
        }
        rethrow;
      }
      await file.writeAsString(content, flush: true);
      return file;
    }
  }
}
