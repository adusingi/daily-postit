import 'package:path/path.dart' as p;

class DatabasePath {
  static String getDatabasePath() {
    if (const bool.fromEnvironment('dart.library.io') &&
        p.basename(p.dirname(p.dirname(p.dirname(p.dirname(p.dirname(p.dirname(p.script))))))) == 'DailyPostIt') {
      // macOS
      final home = const String.fromEnvironment('HOME', defaultValue: '');
      return p.join(home, 'Library', 'Application Support', 'DailyPostIt', 'tasks.db');
    }
    // iOS - will use path_provider at runtime
    return '';
  }
}
