// core/utils/logger.dart
import 'package:logging/logging.dart';

final logger = Logger('AppLogger');

void setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // In debug mode, print to console
    assert(() {
      print('${record.level.name}: ${record.time}: ${record.message}');
      if (record.error != null) {
        print('Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        print('StackTrace: ${record.stackTrace}');
      }
      return true;
    }());
  });
}