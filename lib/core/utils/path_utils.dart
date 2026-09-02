import 'package:control_financiero/core/constants/app_paths.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> getLogsFilePath(DateTime date) async {
  final directory = await getApplicationSupportDirectory();

  final fileName = AppPaths.logsFileName.replaceAll(
    'app_log.log',
    'app_log_${date.toIso8601String().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.log',
  );

  return p.join(
    directory.path,
    AppPaths.logsDirectoryName,
    fileName,
  );
}
