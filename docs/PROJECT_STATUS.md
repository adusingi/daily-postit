---
title: "Daily Post-it - Project Status"
---

# Daily Post-it - Project Status

**Last Updated:** 2026-03-16
**Current Phase:** Project Setup (Phase 1)
**Branch Policy:** Work on `main`, create feature branches for major changes.

---

## Recent updates (2026-03-16)
- Project documentation created
- Following mobayilo project structure and documentation style

---

## ✅ What's already done (documentation)
- [x] PRD defined (`docs/PRD.md`)
- [x] Project summary drafted (`docs/PROJECT_SUMMARY.md`)
- [x] Project status created (`docs/PROJECT_STATUS.md`)

---

## Phase 1: Project Setup (Target: Day 1)
**Objective:** Initialize Flutter project with proper dependencies and folder structure.

**Task checklist (Phase 1)**
- [ ] Create Flutter project (`flutter create --org com.dailypostit --platforms=ios,macos .`)
- [ ] Configure `pubspec.yaml` with required dependencies
- [ ] Set up folder structure (models, screens, widgets, services, utils)
- [ ] Configure macOS app metadata (name, identifier)
- [ ] Configure iOS app metadata (name, identifier, deployment target)
- [ ] Create database path utility for platform-specific paths
- [ ] Verify Flutter builds for macOS simulator
- [ ] Verify Flutter builds for iOS simulator

**Test checklist (Phase 1)**
- [ ] `flutter run -d macos` launches without errors
- [ ] `flutter run -d <ios-device>` launches without errors
- [ ] App icon and name display correctly on macOS
- [ ] App icon and name display correctly on iOS

**Exit criteria:** Flutter project builds successfully for both macOS and iOS targets.

---

## Phase 2: Data Layer (Target: Day 1-2)
**Objective:** Implement Task model and database service with SQLite.

**Task checklist (Phase 2)**
- [ ] Create `Task` model with fields: id, content, date, isDone, hiddenText, createdAt, updatedAt
- [ ] Create `DatabaseService` singleton
- [ ] Initialize SQLite database with tasks table
- [ ] Implement `createTask(Task)` method
- [ ] Implement `updateTask(Task)` method
- [ ] Implement `deleteTask(int id)` method
- [ ] Implement `getTasksForDate(String date)` method
- [ ] Implement `getTaskById(int id)` method
- [ ] Add database path resolution for macOS vs iOS
- [ ] Create database directory if not exists (macOS)

**Test checklist (Phase 2)**
- [ ] Database file created at correct path (macOS: `~/Library/Application Support/DailyPostIt/tasks.db`)
- [ ] Create task returns valid Task with id
- [ ] Update task persists changes
- [ ] Delete task removes from database
- [ ] Get tasks for date returns correct tasks
- [ ] Database schema migrations work (version tracking)

**Exit criteria:** Task model and database service fully functional with CRUD operations.

---

## Phase 3: GUI - Home Screen & Date Navigation (Target: Day 2)
**Objective:** Build home screen with date header and navigation.

**Task checklist (Phase 3)**
- [ ] Create `HomeScreen` with date header displaying today's date
- [ ] Format date as "Monday, March 16, 2026" using intl
- [ ] Add left/right navigation arrows for previous/next day
- [ ] Add date picker for jumping to specific date
- [ ] Implement `DayView` widget for displaying tasks for selected date
- [ ] Show "No tasks yet" empty state when no tasks exist
- [ ] Implement auto-rollover check on app open (unfinished tasks from yesterday move to today)
- [ ] Add light/dark mode theme support via Material 3

**Test checklist (Phase 3)**
- [ ] Today's date displays prominently on app launch
- [ ] Left arrow navigates to previous day
- [ ] Right arrow navigates to next day (disabled for future dates)
- [ ] Date picker allows jumping to any past date
- [ ] Past days are read-only (no editing)
- [ ] Auto-rollver moves yesterday's unfinished tasks to today on first open
- [ ] Light mode renders correctly
- [ ] Dark mode renders correctly

**Exit criteria:** Home screen displays current date with navigation to view any day.

---

## Phase 4: GUI - Markdown Editor & Task Parsing (Target: Day 2-3)
**Objective:** Implement markdown editor with automatic task parsing.

**Task checklist (Phase 4)**
- [ ] Create `MarkdownEditor` widget with TextField
- [ ] Parse markdown bullet points (`- task`, `* task`) into task items
- [ ] Support bold (`**text**`) and italic (`*text*`) rendering
- [ ] Implement auto-save (debounce 500ms after typing stops)
- [ ] Add "Add Task" floating action button
- [ ] Implement simple text input dialog for adding new tasks
- [ ] Sync markdown content to database tasks
- [ ] Handle task content changes and persist to database

**Test checklist (Phase 4)**
- [ ] Typing `- Buy milk` creates a new task
- [ ] Typing `* Call mom` creates a new task (asterisk)
- [ ] Bold text renders correctly
- [ ] Italic text renders correctly
- [ ] Tasks appear in task list below editor
- [ ] Editing markdown updates task list in real-time
- [ ] Data persists after app restart

**Exit criteria:** Markdown editor creates tasks automatically from bullet points.

---

## Phase 5: GUI - Task Item with Checkbox & Hidden Text (Target: Day 3-4)
**Objective:** Implement task items with checkbox toggle and expandable hidden notes.

**Task checklist (Phase 5)**
- [ ] Create `TaskItem` widget with checkbox
- [ ] Implement toggle between Done/Not Done states
- [ ] Add visual strikethrough when task is done
- [ ] Add checkbox animation (scale + color transition)
- [ ] Implement hidden text field below task content
- [ ] Add expand/collapse toggle for hidden text
- [ ] Implement smooth height animation for expand/collapse
- [ ] Add edit option for hidden text
- [ ] Persist hidden text changes to database

**Test checklist (Phase 5)**
- [ ] Tapping checkbox toggles isDone state
- [ ] Done tasks show strikethrough styling
- [ ] Checkbox animates on toggle
- [ ] Hidden text area is collapsed by default
- [ ] Tapping expand icon shows hidden text
- [ ] Hidden text animates smoothly (250ms)
- [ ] Hidden text persists after app restart
- [ ] Task item has proper touch target (48px minimum)

**Exit criteria:** Task items have working checkbox with animation and expandable hidden notes.

---

## Phase 6: CLI Implementation (Target: Day 4-5)
**Objective:** Build complete CLI tool with all commands.

**Task checklist (Phase 6)**
- [ ] Create CLI entry point (`bin/daily_cli.dart`)
- [ ] Set up argument parsing with `args` package
- [ ] Implement `daily list` command
- [ ] Implement `daily list --done` flag
- [ ] Implement `daily list --date YYYY-MM-DD` flag
- [ ] Implement `daily add "Task content"` command
- [ ] Implement `daily done <task-id>` command
- [ ] Implement `daily undone <task-id>` command
- [ ] Implement `daily stats` command (weekly completion rate)
- [ ] Configure shared database path for CLI
- [ ] Add error handling and user-friendly messages
- [ ] Build CLI executable with `dart compile exe`

**Test checklist (Phase 6)**
- [ ] `daily list` shows today's unfinished tasks
- [ ] `daily list --done` shows today's completed tasks
- [ ] `daily list --date 2026-03-15` shows tasks for specific date
- [ ] `daily add "Buy groceries"` creates new task
- [ ] `daily done 1` marks task 1 as done
- [ ] `daily undone 1` marks task 1 as not done
- [ ] `daily stats` shows weekly completion percentage
- [ ] Invalid commands show helpful error message
- [ ] CLI works on macOS without Flutter installed (compiled exe)

**Exit criteria:** All CLI commands work correctly and share database with GUI.

---

## Phase 7: Auto-Rollover Logic (Target: Day 5)
**Objective:** Implement automatic task rollover for unfinished tasks.

**Task checklist (Phase 7)**
- [ ] Implement midnight detection (check on app open)
- [ ] Query all unfinished tasks from previous day
- [ ] Update date field to current date for each unfinished task
- [ ] Preserve original createdAt timestamp
- [ ] Update updatedAt to rollover time
- [ ] Handle edge case: same-day multiple opens (only rollover once)
- [ ] Add rollover status to UI (toast/notification)

**Test checklist (Phase 7)**
- [ ] Opening app on new day moves yesterday's unfinished tasks to today
- [ ] Yesterday's completed tasks stay on yesterday (archived)
- [ ] Opening app multiple times on same day doesn't duplicate rollover
- [ ] Rollover preserves task content and hidden text
- [ ] Rollover updates timestamps correctly

**Exit criteria:** Unfinished tasks automatically move to new day at midnight.

---

## Phase 8: Build & Testing (Target: Day 5-6)
**Objective:** Final build verification for all platforms.

**Task checklist (Phase 8)**
- [ ] Build macOS app (`flutter build macos`)
- [ ] Build iOS app for simulator (`flutter build ios --simulator`)
- [ ] Build iOS app for device (requires provisioning)
- [ ] Test full workflow: create task, toggle done, add note, navigate days
- [ ] Test CLI workflow: add, list, done, undone, stats
- [ ] Verify database shared between GUI and CLI
- [ ] Test light/dark mode on all platforms
- [ ] Test animations (checkbox, expand/collapse)
- [ ] Create build instructions documentation

**Test checklist (Phase 8)**
- [ ] macOS build succeeds without warnings
- [ ] iOS simulator build succeeds without warnings
- [ ] GUI and CLI share same database correctly
- [ ] All features work on macOS
- [ ] All features work on iOS simulator

**Exit criteria:** Builds succeed for macOS and iOS, all features verified working.

---

## Phase 9: Documentation & Polish (Target: Day 6)
**Objective:** Final documentation and polish.

**Task checklist (Phase 9)**
- [ ] Update README with installation instructions
- [ ] Document CLI usage and examples
- [ ] Add screenshots to documentation
- [ ] Verify all Phase exit criteria are met
- [ ] Check for any remaining TODOs in code

**Test checklist (Phase 9)**
- [ ] README is clear and complete
- [ ] CLI documentation is comprehensive
- [ ] No blocking issues remain

**Exit criteria:** Project is documented and ready for use.

---

## What needs to be decided
1. Maximum tasks per day limit (if any)
2. Default placeholder text for hidden notes
3. Keyboard shortcuts for CLI commands
4. Whether to support markdown in hidden text area

---

## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  flutter_markdown: ^0.6.18
  intl: ^0.19.0
  path_provider: ^2.1.1
  args: ^2.4.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```
