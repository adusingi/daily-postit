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
  late FocusNode _textFocusNode;

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
    _textFocusNode = FocusNode();
    
    // Listen to focus changes to keep expanded when typing
    _textFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update text if not currently focused and text changed externally
    if (!_textFocusNode.hasFocus && oldWidget.task.hiddenText != widget.task.hiddenText) {
      _hiddenTextController.text = widget.task.hiddenText ?? '';
    }
  }

  void _onFocusChange() {
    if (_textFocusNode.hasFocus && !_isExpanded) {
      // Auto-expand when text field gets focus
      setState(() {
        _isExpanded = true;
        _expandController.forward();
      });
    }
  }

  @override
  void dispose() {
    _textFocusNode.removeListener(_onFocusChange);
    _expandController.dispose();
    _hiddenTextController.dispose();
    _textFocusNode.dispose();
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
          // Main task row - NOT using InkWell to avoid tap conflicts
          GestureDetector(
            onTap: widget.isReadOnly ? null : _toggleDone,
            behavior: HitTestBehavior.translucent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(12),
                  bottom: _isExpanded ? Radius.zero : const Radius.circular(12),
                ),
              ),
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
                  
                  // Expand button
                  if (!widget.isReadOnly || hasHiddenText)
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: _toggleExpand,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: AnimatedRotation(
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
                        ),
                      ),
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
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            widget.task.hiddenText!,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        )
                      : const SizedBox.shrink())
                  : GestureDetector(
                      // Prevent tap from bubbling up to parent
                      onTap: () {
                        _textFocusNode.requestFocus();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: TextField(
                        controller: _hiddenTextController,
                        focusNode: _textFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Add notes...',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: _updateHiddenText,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
