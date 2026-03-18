import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';

class DayView extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;
  final bool isReadOnly;
  final VoidCallback onTasksChanged;
  final VoidCallback? onAddTask;

  const DayView({
    super.key,
    required this.date,
    required this.tasks,
    required this.isReadOnly,
    required this.onTasksChanged,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isReadOnly ? 'No tasks for this day' : 'No tasks yet',
              style: TextStyle(
                fontSize: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (!isReadOnly && onAddTask != null) ...[
              const SizedBox(height: 16),
              IconButton(
                onPressed: onAddTask,
                icon: const Icon(Icons.add),
                iconSize: 32,
                color: theme.colorScheme.primary,
                tooltip: 'Add task',
              ),
            ],
          ],
        ),
      );
    }

    // Separate done and not done tasks
    final notDoneTasks = tasks.where((t) => !t.isDone).toList();
    final doneTasks = tasks.where((t) => t.isDone).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notDoneTasks.length + doneTasks.length + (doneTasks.isNotEmpty ? 1 : 0) + (onAddTask != null ? 1 : 0),
      itemBuilder: (context, index) {
        // Show add button at the end if there are tasks
        if (onAddTask != null && index == _getTotalItemCount(notDoneTasks.length, doneTasks.length)) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: IconButton(
                onPressed: onAddTask,
                icon: const Icon(Icons.add),
                iconSize: 28,
                color: theme.colorScheme.primary,
                tooltip: 'Add task',
              ),
            ),
          );
        }

        // Show completed section header
        if (doneTasks.isNotEmpty && index == notDoneTasks.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8, left: 8),
            child: Text(
              'Completed',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          );
        }

        Task task;
        if (index < notDoneTasks.length) {
          task = notDoneTasks[index];
        } else {
          final doneIndex = doneTasks.isNotEmpty ? index - notDoneTasks.length - 1 : index - notDoneTasks.length;
          task = doneTasks[doneIndex];
        }

        return TaskItem(
          task: task,
          isReadOnly: isReadOnly,
          onChanged: onTasksChanged,
        );
      },
    );
  }

  int _getTotalItemCount(int notDoneCount, int doneCount) {
    int count = notDoneCount;
    if (doneCount > 0) {
      count += 1; // Header
      count += doneCount;
    }
    return count;
  }
}
