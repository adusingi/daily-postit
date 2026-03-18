import 'dart:async';
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
  bool _isEditingContent = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late TextEditingController _hiddenTextController;
  late TextEditingController _contentController;
  late FocusNode _textFocusNode;
  late FocusNode _contentFocusNode;
  Timer? _hiddenTextDebounce;
  late String _lastSavedHiddenText;

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
    _contentController = TextEditingController(text: widget.task.content);
    _lastSavedHiddenText = widget.task.hiddenText ?? '';
    _textFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
    
    _textFocusNode.addListener(_onFocusChange);
    _contentFocusNode.addListener(_onContentFocusChange);
  }

  @override
  void didUpdateWidget(TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_textFocusNode.hasFocus && oldWidget.task.hiddenText != widget.task.hiddenText) {
      _hiddenTextController.text = widget.task.hiddenText ?? '';
      _lastSavedHiddenText = widget.task.hiddenText ?? '';
    }
  }

  @override
  void dispose() {
    _textFocusNode.removeListener(_onFocusChange);
    _contentFocusNode.removeListener(_onContentFocusChange);
    _hiddenTextDebounce?.cancel();
    _flushHiddenText();
    // Unfocus before disposing to prevent callbacks
    _contentFocusNode.unfocus();
    _textFocusNode.unfocus();
    _contentFocusNode.dispose();
    _textFocusNode.dispose();
    _contentController.dispose();
    _hiddenTextController.dispose();
    // Stop animation before disposing
    _expandController.stop();
    _expandController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_textFocusNode.hasFocus && !_isExpanded && mounted) {
      setState(() {
        _isExpanded = true;
        _expandController.forward();
      });
    }
    if (!_textFocusNode.hasFocus) {
      _flushHiddenText();
    }
  }

  void _onContentFocusChange() {
    if (!_contentFocusNode.hasFocus && _isEditingContent) {
      _saveContent();
      if (mounted) {
        setState(() {
          _isEditingContent = false;
        });
      }
    }
  }

  void _startEditingContent() {
    if (widget.isReadOnly || widget.task.isDone) return;
    setState(() {
      _isEditingContent = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentFocusNode.requestFocus();
    });
  }

  Future<void> _saveContent() async {
    final newContent = _contentController.text.trim();
    if (newContent.isEmpty || newContent == widget.task.content) return;

    final updated = widget.task.copyWith(
      content: newContent,
      updatedAt: DateTime.now(),
    );

    await DatabaseService.instance.updateTask(updated);
    if (mounted) {
      widget.onChanged();
    }
  }

  void _toggleExpand() {
    if (!mounted) return;
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
    if (widget.isReadOnly) return;
    _hiddenTextDebounce?.cancel();
    _hiddenTextDebounce = Timer(const Duration(milliseconds: 400), () {
      _persistHiddenText(text);
    });
  }

  Future<void> _persistHiddenText(String text) async {
    if (text == _lastSavedHiddenText) return;

    final updated = widget.task.copyWith(
      hiddenText: text.isEmpty ? null : text,
      updatedAt: DateTime.now(),
    );

    await DatabaseService.instance.updateTask(updated);
    _lastSavedHiddenText = text;
  }

  Future<void> _flushHiddenText() async {
    _hiddenTextDebounce?.cancel();
    await _persistHiddenText(_hiddenTextController.text);
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(12),
                bottom: _isExpanded ? Radius.zero : const Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Checkbox - only tappable area to mark as done
                GestureDetector(
                  onTap: widget.isReadOnly ? null : _toggleDone,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
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
                ),
                const SizedBox(width: 12),
                
                // Task content - editable
                Expanded(
                  child: _isEditingContent
                      ? TextField(
                          controller: _contentController,
                          focusNode: _contentFocusNode,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: null,
                          onSubmitted: (_) {
                            _saveContent();
                            setState(() {
                              _isEditingContent = false;
                            });
                          },
                        )
                      : GestureDetector(
                          onTap: widget.isReadOnly ? null : _startEditingContent,
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
