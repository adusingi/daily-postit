import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class RolloverService {
  static const String _lastRolloverKey = 'lastRolloverDate';
  
  final DatabaseService _dbService;
  
  RolloverService(this._dbService);
  
  /// Checks if rollover is needed and performs it
  /// Returns true if rollover was performed
  Future<bool> checkAndRollover() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRollover = prefs.getString(_lastRolloverKey);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Check if we've already rolled over today
    if (lastRollover == today) {
      return false;
    }
    
    // Calculate yesterday's date
    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));
    
    // Check if there are unfinished tasks from yesterday
    final yesterdayTasks = await _dbService.getTasksForDate(yesterday);
    final unfinishedTasks = yesterdayTasks.where((t) => !t.isDone).toList();
    
    if (unfinishedTasks.isEmpty) {
      // No unfinished tasks to rollover, just update the last rollover date
      await prefs.setString(_lastRolloverKey, today);
      return false;
    }
    
    // Perform rollover
    await _dbService.rolloverTasks(yesterday, today);
    
    // Update last rollover date
    await prefs.setString(_lastRolloverKey, today);
    
    return true;
  }
  
  /// Gets the count of tasks that would be rolled over
  Future<int> getRolloverCount() async {
    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));
    
    final yesterdayTasks = await _dbService.getTasksForDate(yesterday);
    return yesterdayTasks.where((t) => !t.isDone).length;
  }
  
  /// Resets the last rollover date (useful for testing)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRolloverKey);
  }
}
