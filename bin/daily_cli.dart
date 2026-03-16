import 'dart:io';

// Import the CLI implementation directly
// Note: This file should be run from the project root
// For production, we should compile this to an executable
import '../lib/cli.dart' as cli;

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('Daily Post-it CLI');
    print('');
    print('Usage:');
    print('  daily list                   - Show today\'s unfinished tasks');
    print('  daily list --done            - Show today\'s completed tasks');
    print('  daily list --date 2026-03-15 - Show tasks for specific date');
    print('  daily add "Task content"     - Add new task for today');
    print('  daily done <task-id>         - Mark task as done');
    print('  daily undone <task-id>       - Mark task as not done');
    print('  daily stats                  - Show weekly completion rate');
    print('');
    exit(0);
  }

  cli.main(arguments);
}
