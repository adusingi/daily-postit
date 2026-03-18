import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../services/rollover_service.dart';
import '../models/task.dart';
import 'day_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Task> _tasks = [];
  bool _isLoading = true;
  List<DateTime> _pastDays = [];
  final Set<String> _expandedPastDays = {};
  final Map<String, List<Task>> _pastDayTasks = {};
  final Set<String> _loadingPastDays = {};

  @override
  void initState() {
    super.initState();
    _checkAndRollover();
    _loadTasks();
  }

  Future<void> _checkAndRollover() async {
    final rolloverService = RolloverService(DatabaseService.instance);
    final rolledOver = await rolloverService.checkAndRollover();
    
    if (rolledOver && mounted) {
      // Show a snackbar to inform user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unfinished tasks from yesterday moved to today'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final tasksFuture = DatabaseService.instance.getTasksForDate(dateStr);
    final pastDatesFuture = _isToday
        ? DatabaseService.instance.getTaskDatesBefore(dateStr)
        : Future.value(<String>[]);

    final results = await Future.wait([tasksFuture, pastDatesFuture]);
    final tasks = results[0] as List<Task>;
    final pastDates = results[1] as List<String>;

    setState(() {
      _tasks = tasks;
      _isLoading = false;
      if (_isToday) {
        _pastDays = pastDates.map(DateTime.parse).toList();
      } else {
        _pastDays = [];
        _expandedPastDays.clear();
        _pastDayTasks.clear();
        _loadingPastDays.clear();
      }
    });
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _loadTasks();
  }

  void _goToNextDay() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (_selectedDate.isBefore(DateTime(tomorrow.year, tomorrow.month, tomorrow.day))) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      });
      _loadTasks();
    }
  }

  Future<void> _togglePastDay(String dateStr) async {
    if (_expandedPastDays.contains(dateStr)) {
      setState(() {
        _expandedPastDays.remove(dateStr);
      });
      return;
    }

    setState(() {
      _expandedPastDays.add(dateStr);
    });

    if (_pastDayTasks.containsKey(dateStr)) {
      return;
    }

    setState(() {
      _loadingPastDays.add(dateStr);
    });

    final tasks = await DatabaseService.instance.getTasksForDate(dateStr);
    if (!mounted) return;
    setState(() {
      _pastDayTasks[dateStr] = tasks;
      _loadingPastDays.remove(dateStr);
    });
  }

  Future<void> _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      _loadTasks();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    
    if (selected == today) {
      return 'Today';
    }
    
    final yesterday = today.subtract(const Duration(days: 1));
    if (selected == yesterday) {
      return 'Yesterday';
    }
    
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
           _selectedDate.month == now.month &&
           _selectedDate.day == now.day;
  }

  Future<void> _showAddTaskDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _AddTaskDialog(),
    );
    
    if (result != null && result.isNotEmpty) {
      final task = Task(
        content: result,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await DatabaseService.instance.createTask(task);
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // Date Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Add button (top left)
                  if (_isToday)
                    IconButton(
                      onPressed: _showAddTaskDialog,
                      icon: const Icon(Icons.add),
                      tooltip: 'Add task',
                    )
                  else
                    const SizedBox(width: 48), // Spacer for alignment
                  
                  // Previous day button
                  IconButton(
                    onPressed: _goToPreviousDay,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous day',
                  ),
                  
                  // Date display
                  Expanded(
                    child: GestureDetector(
                      onTap: _showDatePicker,
                      child: Column(
                        children: [
                          Text(
                            _formatDate(_selectedDate),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (!_isToday)
                            Text(
                              DateFormat('MMM d, y').format(_selectedDate),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Next day button
                  IconButton(
                    onPressed: _isToday ? null : _goToNextDay,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next day',
                  ),
                  
                  // Spacer for symmetry
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            // Day View
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DayView(
                      date: _selectedDate,
                      tasks: _tasks,
                      isReadOnly: !_isToday,
                      onTasksChanged: _loadTasks,
                      onAddTask: _isToday ? _showAddTaskDialog : null,
                      pastDays: _isToday ? _pastDays : const [],
                      expandedPastDays: _expandedPastDays,
                      pastDayTasks: _pastDayTasks,
                      loadingPastDays: _loadingPastDays,
                      onTogglePastDay: _togglePastDay,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog();

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Enter task...',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
