import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';

class DayView extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;
  final bool isReadOnly;
  final VoidCallback onTasksChanged;

  const DayView({
    super.key,
    required this.date,
    required this.tasks,
    required this.isReadOnly,
    required this.onTasksChanged,
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
            if (!isReadOnly) ...[
              const SizedBox(height: 8),
              Text(
                'Tap + to add your first task',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
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
      itemCount: notDoneTasks.length + doneTasks.length + (doneTasks.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
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
}
