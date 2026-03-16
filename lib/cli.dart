import 'dart:io';
import 'package:args/args.dart';
import 'package:intl/intl.dart';
import 'services/database_service.dart';
import 'models/task.dart';

void main(List<String> arguments) async {
  final listParser = ArgParser()
    ..addFlag('done', abbr: 'd', defaultsTo: false, negatable: false)
    ..addOption('date', abbr: 'D');
  
  final parser = ArgParser()
    ..addCommand('list', listParser)
    ..addCommand('add')
    ..addCommand('done')
    ..addCommand('undone')
    ..addCommand('stats');

  final results = parser.parse(arguments);
  final dbService = DatabaseService.instance;

  try {
    final command = results.command?.name ?? 'list';

    switch (command) {
      case 'list':
        await handleList(results.command!, dbService);
        break;
      case 'add':
        await handleAdd(results.command!, dbService);
        break;
      case 'done':
        await handleDone(results.command!, dbService);
        break;
      case 'undone':
        await handleUndone(results.command!, dbService);
        break;
      case 'stats':
        await handleStats(dbService);
        break;
      default:
        print('Unknown command: $command');
        exit(1);
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

Future<void> handleList(ArgResults command, DatabaseService dbService) async {
  final done = command.flag('done', abbr: 'd', defaultsTo: false);
  final dateArg = command.option('date');
  final date = dateArg ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

  final tasks = await dbService.getTasksForDate(date);
  final filtered = done
      ? tasks.where((t) => t.isDone).toList()
      : tasks.where((t) => !t.isDone).toList();

  print('\nTasks for $date${done ? ' (done)' : ''}:\n');
  if (filtered.isEmpty) {
    print('  No tasks found.\n');
    return;
  }

  for (var task in filtered) {
    final status = task.isDone ? '[✓]' : '[ ]';
    print('  $status ${task.id}: ${task.content}');
    if (task.hiddenText != null && task.hiddenText!.isNotEmpty) {
      print('      Note: ${task.hiddenText}');
    }
  }
  print('');
}

Future<void> handleAdd(ArgResults command, DatabaseService dbService) async {
  final rest = command.rest;
  if (rest.isEmpty) {
    print('Usage: daily add "Task content"');
    exit(1);
  }

  final content = rest.join(' ');
  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final task = Task(
    content: content,
    date: date,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final id = await dbService.createTask(task);
  print('Added task #$id: $content\n');
}

Future<void> handleDone(ArgResults command, DatabaseService dbService) async {
  final rest = command.rest;
  if (rest.isEmpty) {
    print('Usage: daily done <task-id>');
    exit(1);
  }

  final id = int.tryParse(rest.first);
  if (id == null) {
    print('Invalid task ID');
    exit(1);
  }

  final task = await dbService.getTaskById(id);
  if (task == null) {
    print('Task #$id not found');
    exit(1);
  }

  final updated = task.copyWith(isDone: true, updatedAt: DateTime.now());
  await dbService.updateTask(updated);
  print('Task marked as done: ${task.content}\n');
}

Future<void> handleUndone(ArgResults command, DatabaseService dbService) async {
  final rest = command.rest;
  if (rest.isEmpty) {
    print('Usage: daily undone <task-id>');
    exit(1);
  }

  final id = int.tryParse(rest.first);
  if (id == null) {
    print('Invalid task ID');
    exit(1);
  }

  final task = await dbService.getTaskById(id);
  if (task == null) {
    print('Task #$id not found');
    exit(1);
  }

  final updated = task.copyWith(isDone: false, updatedAt: DateTime.now());
  await dbService.updateTask(updated);
  print('Task marked as not done: ${task.content}\n');
}

Future<void> handleStats(DatabaseService dbService) async {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final dates = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

  print('\nWeekly Stats:\n');
  int total = 0;
  int done = 0;

  for (final date in dates) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final tasks = await dbService.getTasksForDate(dateStr);
    total += tasks.length;
    done += tasks.where((t) => t.isDone).length;
  }

  final percentage =
      total > 0 ? (done / total * 100).toStringAsFixed(1) : '0.0';
  print('  Total tasks: $total');
  print('  Completed: $done');
  print('  Completion rate: $percentage%\n');
}
