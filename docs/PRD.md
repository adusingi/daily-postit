---
title: "PRD: Daily Post-it"
---

# PRD: Daily Post-it

## 1) Summary
Daily Post-it is a minimalist daily todo application with CLI companion for macOS, iOS, and iPadOS. Users manage daily tasks through a clean markdown editor, with tasks automatically parsed from bullet points. Each task has binary Done/Not Done states with optional hidden notes. A macOS CLI tool provides command-line access to the same task database.

## 2) Goals / Non-goals

### Goals (MVP)
- Clean, distraction-free daily task management interface
- Binary task completion (Done / Not Done) with visual feedback
- Expandable hidden notes for each task
- Automatic rollover of unfinished tasks to new day
- CLI tool for power users on macOS
- Light/dark mode support
- Smooth animations for interactions

### Non-goals (MVP)
- Categories, tags, or priorities
- Reminders or notifications
- Cloud sync or authentication
- Task dependencies or sub-tasks
- Cross-platform sync
- Android support (Phase 2+)

## 3) Target users & primary use cases

### Personas
- **Daily user**: Uses the app daily for simple task tracking
- **CLI power user**: Prefers command-line for quick task management on macOS
- **Minimalist**: Wants simple, no-frills daily todos

### Primary use cases
- Open app, see today's date prominently displayed
- Type markdown bullet points that become tasks
- Check off tasks as completed with visual feedback
- Add private notes to tasks (hidden by default)
- Open app next day to see unfinished tasks auto-rolled
- Use CLI to quickly add/check tasks from terminal

## 4) Success metrics (MVP)
- App launch to usable state < 2 seconds
- Task creation from markdown < 100ms
- CLI command execution < 500ms
- Smooth 60fps animations
- Zero data loss (database integrity)

## 5) User journeys (MVP)

### A) First-time use
1. User opens app, sees today's date prominently
2. User types `- Call mom` in markdown editor
3. Task "Call mom" appears in task list below
4. User taps checkbox to mark done
5. Task shows strikethrough styling

### B) Returning user (next day)
1. User opens app
2. App checks for unfinished tasks from yesterday
3. Unfinished tasks automatically moved to today
4. User sees today's tasks ready to work on

### C) CLI user
1. User opens Terminal
2. Types `daily add "Review PR #42"`
3. Task added to today's list
4. Types `daily list` to see tasks
5. Types `daily done 1` when complete

### D) Adding hidden notes
1. User taps expand icon on task
2. Hidden text area expands with animation
3. User types private notes
4. Notes stay collapsed by default

## 6) Product requirements

### 6.1 Daily markdown editor
- Today's date displayed prominently at top
- Clean text input area for markdown
- Auto-parse bullet points (`- task`, `* task`) into tasks
- Support bold (`**text**`) and italic (`*text*`)
- Support bullet lists (ordered and unordered)
- Auto-save after 500ms of no typing

### 6.2 Task management
- Each task has exactly two states: **Done** or **Not Done**
- No progress percentages or custom states
- Checkbox to toggle status
- Visual strikethrough when task is done
- Checkbox animation: 200ms scale + color transition
- Minimum touch target: 48px height

### 6.3 Hidden notes
- Optional hidden text field attached to each task
- Hidden by default (collapsed)
- Tap to expand/collapse
- Animation: 250ms ease-in-out height transition
- Expand icon indicates collapsed state
- Persist hidden text to database

### 6.4 Date navigation
- Show current date prominently: "Monday, March 16, 2026"
- Left arrow: navigate to previous day
- Right arrow: navigate to next day (disabled for future)
- Date picker: jump to specific date
- Past days: read-only mode
- Future days: disabled (no navigation)

### 6.5 Auto-rollover
- On app open, check if date has changed
- Query all unfinished tasks from previous day
- Update date to current date
- Preserve original createdAt timestamp
- Completed tasks stay on original day (archived)
- Only rollover once per day (track last rollover date)

### 6.6 CLI tool (macOS only)
- Separate Dart executable sharing same SQLite database
- Commands:
  - `daily list` — show today's unfinished tasks
  - `daily list --done` — show today's completed tasks
  - `daily list --date YYYY-MM-DD` — show tasks for specific date
  - `daily add "Task content"` — add new task for today
  - `daily done <task-id>` — mark task as done
  - `daily undone <task-id>` — mark task as not done
  - `daily stats` — show completion rate for current week

## 7) Technical requirements

### 7.1 Stack
- **Framework:** Flutter (latest stable)
- **Targets:** macOS, iOS, iPadOS
- **Database:** SQLite (sqflite package)
- **State management:** Flutter Provider or simple setState

### 7.2 Database
- **Location (macOS):** `~/Library/Application Support/DailyPostIt/tasks.db`
- **Location (iOS):** App documents directory
- **Schema:**
  ```sql
  CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL,
    date TEXT NOT NULL,
    is_done INTEGER DEFAULT 0,
    hidden_text TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  );
  CREATE INDEX idx_tasks_date ON tasks(date);
  CREATE INDEX idx_tasks_date_is_done ON tasks(date, is_done);
  ```

### 7.3 Dependencies
- `sqflite` - SQLite database
- `flutter_markdown` - Markdown rendering
- `intl` - Date formatting
- `args` - CLI argument parsing
- `path_provider` - Platform-specific paths

### 7.4 UI/UX
- Material Design 3
- Light/dark mode via theme
- Apple Notes aesthetic (clean, minimalist)
- Native window controls on macOS
- Full-screen optimized on iOS/iPadOS

## 8) Design requirements

### 8.1 Visual design
- Clean, Apple Notes-inspired aesthetic
- Primary color: #007AFF (iOS blue)
- Surface: White (#FFFFFF)
- Background: #F5F5F7
- Text: #1D1D1F (primary), #86868B (secondary)
- Success: #34C759 (green for completed)

### 8.2 Animations
- Checkbox toggle: 200ms ease-out
- Hidden text expand/collapse: 250ms ease-in-out
- Page transitions: default Flutter

### 8.3 Typography
- Date header: Large, prominent
- Task content: Readable body text
- Timestamps: Small, muted

## 9) Open questions

1. **Maximum tasks per day:** Should there be a limit? If so, what?
2. **Default placeholder:** What text shows in hidden notes before user adds content?
3. **Markdown in notes:** Should hidden notes also support markdown?
4. **CLI shortcuts:** Should we add short aliases (e.g., `d` for `done`)?
5. **Data export:** Should we add export functionality (JSON/CSV)?

---

## Implementation notes

### Database path resolution
```dart
// macOS
String dbPath = path.join(
  Platform.environment['HOME']!,
  'Library',
  'Application Support',
  'DailyPostIt',
  'tasks.db'
);

// iOS
String dbPath = await getApplicationDocumentsDirectory();
```

### Auto-rollover logic
```dart
Future<void> checkAndRollover() async {
  final lastRollover = prefs.getString('lastRolloverDate');
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  if (lastRollover != today) {
    final yesterday = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(Duration(days: 1)));
    
    await dbService.rolloverTasks(yesterday, today);
    await prefs.setString('lastRolloverDate', today);
  }
}
```

### Markdown parsing
```dart
List<Task> parseMarkdown(String content) {
  final lines = content.split('\n');
  final tasks = <Task>[];
  
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
      tasks.add(Task(content: trimmed.substring(2)));
    }
  }
  
  return tasks;
}
```
