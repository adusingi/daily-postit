import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final bool isReadOnly;
  final VoidCallback onChanged;

  const TaskItem({
    super.key,
    required this.task,
    required this.isReadOnly,
    required this.onChanged,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late TextEditingController _hiddenTextController;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _hiddenTextController = TextEditingController(text: widget.task.hiddenText ?? '');
  }

  @override
  void didUpdateWidget(TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller text if task changed externally (e.g., from CLI)
    if (oldWidget.task.hiddenText != widget.task.hiddenText) {
      _hiddenTextController.text = widget.task.hiddenText ?? '';
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _hiddenTextController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  Future<void> _toggleDone() async {
    if (widget.isReadOnly) return;

    final updated = widget.task.copyWith(
      isDone: !widget.task.isDone,
      updatedAt: DateTime.now(),
    );

    await DatabaseService.instance.updateTask(updated);
    widget.onChanged();
  }

  Future<void> _updateHiddenText(String text) async {
    final updated = widget.task.copyWith(
      hiddenText: text.isEmpty ? null : text,
      updatedAt: DateTime.now(),
    );

    await DatabaseService.instance.updateTask(updated);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasHiddenText = widget.task.hiddenText != null && widget.task.hiddenText!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Main task row
          InkWell(
            onTap: widget.isReadOnly ? null : _toggleDone,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: widget.task.isDone
                          ? const Color(0xFF34C759)
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.task.isDone
                            ? const Color(0xFF34C759)
                            : theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: widget.task.isDone
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Task content
                  Expanded(
                    child: Text(
                      widget.task.content,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: widget.task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: widget.task.isDone
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  
                  // Expand button (if not read-only or has hidden text)
                  if (!widget.isReadOnly || hasHiddenText)
                    IconButton(
                      onPressed: _toggleExpand,
                      icon: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          hasHiddenText ? Icons.notes : Icons.expand_more,
                          size: 20,
                          color: hasHiddenText
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      tooltip: _isExpanded ? 'Collapse' : 'Expand',
                    ),
                ],
              ),
            ),
          ),
          
          // Hidden text area
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(48, 0, 16, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F7),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: widget.isReadOnly
                  ? (hasHiddenText
                      ? Text(
                          widget.task.hiddenText!,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        )
                      : const SizedBox.shrink())
                  : TextField(
                      controller: _hiddenTextController,
                      decoration: InputDecoration(
                        hintText: 'Add notes...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                      maxLines: null,
                      onChanged: _updateHiddenText,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
