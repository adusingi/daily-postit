import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
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

  @override
  void initState() {
    super.initState();
    _checkAndRollover();
    _loadTasks();
  }

  Future<void> _checkAndRollover() async {
    // TODO: Implement rollover logic
    // This will be done in a separate commit
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final tasks = await DatabaseService.instance.getTasksForDate(dateStr);

    setState(() {
      _tasks = tasks;
      _isLoading = false;
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
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isToday
          ? FloatingActionButton.extended(
              onPressed: () => _showAddTaskDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            )
          : null,
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter task...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
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
    
    controller.dispose();
  }
}
