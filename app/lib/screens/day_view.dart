import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';

class DayView extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;
  final bool isReadOnly;
  final VoidCallback onTasksChanged;
  final VoidCallback? onAddTask;
  final List<DateTime> pastDays;
  final Set<String> expandedPastDays;
  final Map<String, List<Task>> pastDayTasks;
  final Set<String> loadingPastDays;
  final Future<void> Function(String dateStr)? onTogglePastDay;

  const DayView({
    super.key,
    required this.date,
    required this.tasks,
    required this.isReadOnly,
    required this.onTasksChanged,
    this.onAddTask,
    this.pastDays = const <DateTime>[],
    this.expandedPastDays = const <String>{},
    this.pastDayTasks = const <String, List<Task>>{},
    this.loadingPastDays = const <String>{},
    this.onTogglePastDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Separate done and not done tasks
    final notDoneTasks = tasks.where((t) => !t.isDone).toList();
    final doneTasks = tasks.where((t) => t.isDone).toList();

    final children = <Widget>[];

    if (tasks.isEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
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
        ),
      );
    } else {
      for (final task in notDoneTasks) {
        children.add(
          TaskItem(
            task: task,
            isReadOnly: isReadOnly,
            onChanged: onTasksChanged,
          ),
        );
      }

      if (doneTasks.isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8, left: 8),
            child: Text(
              'Completed',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        );

        for (final task in doneTasks) {
          children.add(
            TaskItem(
              task: task,
              isReadOnly: isReadOnly,
              onChanged: onTasksChanged,
            ),
          );
        }
      }

      if (onAddTask != null) {
        children.add(
          Padding(
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
          ),
        );
      }
    }

    if (pastDays.isNotEmpty) {
      children.add(const SizedBox(height: 24));
      for (final pastDay in pastDays) {
        final dateStr = DateFormat('yyyy-MM-dd').format(pastDay);
        children.add(
          _PastDaySection(
            date: pastDay,
            isExpanded: expandedPastDays.contains(dateStr),
            isLoading: loadingPastDays.contains(dateStr),
            tasks: pastDayTasks[dateStr] ?? const <Task>[],
            onToggle: onTogglePastDay == null ? null : () => onTogglePastDay!(dateStr),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }
}

class _PastDaySection extends StatelessWidget {
  final DateTime date;
  final bool isExpanded;
  final bool isLoading;
  final List<Task> tasks;
  final VoidCallback? onToggle;

  const _PastDaySection({
    required this.date,
    required this.isExpanded,
    required this.isLoading,
    required this.tasks,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dayLabel = DateFormat('EEE').format(date);
    final dateLabel = DateFormat('MMM d, y').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$dayLabel | $dateLabel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : Column(
                      children: tasks.isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'No tasks for this day',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ]
                          : tasks
                              .map(
                                (task) => TaskItem(
                                  task: task,
                                  isReadOnly: true,
                                  onChanged: () {},
                                ),
                              )
                              .toList(),
                    ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
