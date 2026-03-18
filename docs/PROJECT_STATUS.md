---
title: "Daily Post-it - Project Status"
---

# Daily Post-it - Project Status

**Last Updated:** 2026-03-18
**Current Phase:** Phase 8 - Build & Testing
**Branch Policy:** Work on `development`, create feature branches for major changes.

---

## Recent updates (2026-03-18)
- ✅ Refactored repo into monorepo layout with Flutter app under `app/`
- ✅ Past days listed as collapsible rows under Today (tasks hidden until expanded)
- ✅ Sparkle updater disabled in Debug until configured (prevents startup error)
- ✅ Go CLI fully implemented and tested (all 7 commands working)
- ✅ Flutter GUI fully implemented (HomeScreen, DayView, TaskItem)
- ✅ Auto-rollover service with shared_preferences
- ✅ macOS app built successfully (42.5MB)
- ✅ iOS simulator build successful
- ✅ Database sharing between GUI and CLI verified

---

## ✅ What's already done (documentation)
- [x] PRD defined (`docs/PRD.md`)
- [x] Project summary drafted (`docs/PROJECT_SUMMARY.md`)
- [x] Project status created (`docs/PROJECT_STATUS.md`)

---

## Phase 1: Project Setup (Target: Day 1) ✅ COMPLETE
**Objective:** Initialize Flutter project with proper dependencies and folder structure.

**Task checklist (Phase 1)**
- [x] Create Flutter project (`flutter create --org com.dailypostit --platforms=ios,macos .`, now under `app/`)
- [x] Configure `pubspec.yaml` with required dependencies
- [x] Set up folder structure (models, screens, widgets, services, utils)
- [x] Configure macOS app metadata (name, identifier)
- [x] Configure iOS app metadata (name, identifier, deployment target)
- [x] Create database path utility for platform-specific paths
- [x] Verify Flutter builds for macOS simulator
- [x] Verify Flutter builds for iOS simulator

**Test checklist (Phase 1)**
- [x] `cd app && flutter run -d macos` launches without errors
- [x] `cd app && flutter run -d <ios-device>` launches without errors
- [x] App icon and name display correctly on macOS
- [x] App icon and name display correctly on iOS

**Exit criteria:** Flutter project builds successfully for both macOS and iOS targets. ✅

---

## Phase 2: Data Layer (Target: Day 1-2) ✅ COMPLETE
**Objective:** Implement Task model and database service with SQLite.

**Task checklist (Phase 2)**
- [x] Create `Task` model with fields: id, content, date, isDone, hiddenText, createdAt, updatedAt
- [x] Create `DatabaseService` singleton
- [x] Initialize SQLite database with tasks table
- [x] Implement `createTask(Task)` method
- [x] Implement `updateTask(Task)` method
- [x] Implement `deleteTask(int id)` method
- [x] Implement `getTasksForDate(String date)` method
- [x] Implement `getTaskById(int id)` method
- [x] Add database path resolution for macOS vs iOS
- [x] Create database directory if not exists (macOS)

**Test checklist (Phase 2)**
- [x] Database file created at correct path (macOS: `~/Library/Application Support/DailyPostIt/tasks.db`)
- [x] Create task returns valid Task with id
- [x] Update task persists changes
- [x] Delete task removes from database
- [x] Get tasks for date returns correct tasks
- [x] Database schema migrations work (version tracking)

**Exit criteria:** Task model and database service fully functional with CRUD operations. ✅

---

## Phase 3: GUI - Home Screen & Date Navigation (Target: Day 2) ✅ COMPLETE
**Objective:** Build home screen with date header and navigation.

**Task checklist (Phase 3)**
- [x] Create `HomeScreen` with date header displaying today's date
- [x] Format date as "Monday, March 16, 2026" using intl
- [x] Add left/right navigation arrows for previous/next day
- [x] Add date picker for jumping to specific date
- [x] Implement `DayView` widget for displaying tasks for selected date
- [x] Show "No tasks yet" empty state when no tasks exist
- [x] Implement auto-rollover check on app open (unfinished tasks from yesterday move to today)
- [x] Add light/dark mode theme support via Material 3
- [x] Show past days as collapsible rows under Today (tasks hidden until expanded)

**Test checklist (Phase 3)**
- [x] Today's date displays prominently on app launch
- [x] Left arrow navigates to previous day
- [x] Right arrow navigates to next day (disabled for future dates)
- [x] Date picker allows jumping to any past date
- [x] Past days are read-only (no editing)
- [x] Auto-rollver moves yesterday's unfinished tasks to today on first open
- [x] Light mode renders correctly
- [x] Dark mode renders correctly
- [x] Past days list expands/collapses and shows tasks on demand

**Exit criteria:** Home screen displays current date with navigation to view any day. ✅

---

## Phase 4: GUI - Markdown Editor & Task Parsing (Target: Day 2-3) ⏭️ DEFERRED
**Objective:** Implement markdown editor with automatic task parsing.

**Note:** Based on UX review, the direct task input via dialog is more intuitive than markdown parsing for this use case. The add task dialog has been implemented instead.

**Task checklist (Phase 4)**
- [x] Create add task dialog for quick task entry
- [x] Implement simple text input for adding new tasks
- [ ] ~~Parse markdown bullet points (`- task`, `* task`) into task items~~ (deferred)
- [ ] ~~Support bold (`**text**`) and italic (`*text*`) rendering~~ (deferred)
- [ ] ~~Implement auto-save (debounce 500ms after typing stops)~~ (deferred)

**Exit criteria:** Tasks can be created easily via dialog. ✅

---

## Phase 5: GUI - Task Item with Checkbox & Hidden Text (Target: Day 3-4) ✅ COMPLETE
**Objective:** Implement task items with checkbox toggle and expandable hidden notes.

**Task checklist (Phase 5)**
- [x] Create `TaskItem` widget with checkbox
- [x] Implement toggle between Done/Not Done states
- [x] Add visual strikethrough when task is done
- [x] Add checkbox animation (scale + color transition)
- [x] Implement hidden text field below task content
- [x] Add expand/collapse toggle for hidden text
- [x] Implement smooth height animation for expand/collapse
- [x] Add edit option for hidden text
- [x] Persist hidden text changes to database

**Test checklist (Phase 5)**
- [x] Tapping checkbox toggles isDone state
- [x] Done tasks show strikethrough styling
- [x] Checkbox animates on toggle
- [x] Hidden text area is collapsed by default
- [x] Tapping expand icon shows hidden text
- [x] Hidden text animates smoothly (250ms)
- [x] Hidden text persists after app restart
- [x] Task item has proper touch target (48px minimum)

**Exit criteria:** Task items have working checkbox with animation and expandable hidden notes. ✅

---

## Phase 6: CLI Implementation (Target: Day 4-5) ✅ COMPLETE
**Objective:** Build complete CLI tool with all commands in Go.

**Task checklist (Phase 6)**
- [x] Create Go CLI project structure (`cli/`)
- [x] Set up argument parsing with `flag` package
- [x] Implement `daily list` command
- [x] Implement `daily list --done` flag
- [x] Implement `daily list --date YYYY-MM-DD` flag
- [x] Implement `daily add "Task content"` command
- [x] Implement `daily done <task-id>` command
- [x] Implement `daily undone <task-id>` command
- [x] Implement `daily stats` command (weekly completion rate)
- [x] Configure shared database path for CLI
- [x] Add error handling and user-friendly messages
- [x] Build CLI executable (6MB optimized binary)

**Test checklist (Phase 6)**
- [x] `daily list` shows today's unfinished tasks
- [x] `daily list --done` shows today's completed tasks
- [x] `daily list --date 2026-03-15` shows tasks for specific date
- [x] `daily add "Buy groceries"` creates new task
- [x] `daily done 1` marks task 1 as done
- [x] `daily undone 1` marks task 1 as not done
- [x] `daily stats` shows weekly completion percentage
- [x] Invalid commands show helpful error message
- [x] CLI works on macOS without Flutter installed (compiled exe)

**Exit criteria:** All CLI commands work correctly and share database with GUI. ✅

---

## Phase 7: Auto-Rollover Logic (Target: Day 5) ✅ COMPLETE
**Objective:** Implement automatic task rollover for unfinished tasks.

**Task checklist (Phase 7)**
- [x] Implement midnight detection (check on app open)
- [x] Query all unfinished tasks from previous day
- [x] Update date field to current date for each unfinished task
- [x] Preserve original createdAt timestamp
- [x] Update updatedAt to rollover time
- [x] Handle edge case: same-day multiple opens (only rollover once)
- [x] Add rollover status to UI (toast/notification)

**Test checklist (Phase 7)**
- [x] Opening app on new day moves yesterday's unfinished tasks to today
- [x] Yesterday's completed tasks stay on yesterday (archived)
- [x] Opening app multiple times on same day doesn't duplicate rollover
- [x] Rollover preserves task content and hidden text
- [x] Rollover updates timestamps correctly

**Exit criteria:** Unfinished tasks automatically move to new day at midnight. ✅

---

## Phase 8: Build & Testing (Target: Day 5-6) ✅ COMPLETE
**Objective:** Final build verification for all platforms.

**Task checklist (Phase 8)**
- [x] Build macOS app (`flutter build macos`)
- [x] Build iOS app for simulator (`flutter build ios --simulator`)
- [x] Build iOS app for device (requires provisioning)
- [x] Test full workflow: create task, toggle done, add note, navigate days
- [x] Test CLI workflow: add, list, done, undone, stats
- [x] Verify database shared between GUI and CLI
- [x] Test light/dark mode on all platforms
- [x] Test animations (checkbox, expand/collapse)
- [x] Create build instructions documentation

**Test checklist (Phase 8)**
- [x] macOS build succeeds without warnings
- [x] iOS simulator build succeeds without warnings
- [x] GUI and CLI share same database correctly
- [x] All features work on macOS
- [x] All features work on iOS simulator

**Exit criteria:** Builds succeed for macOS and iOS, all features verified working. ✅

---

## Phase 9: Documentation & Polish (Target: Day 6) 🔄 IN PROGRESS
**Objective:** Final documentation and polish.

**Task checklist (Phase 9)**
- [ ] Update README with installation instructions
- [ ] Document CLI usage and examples
- [ ] Add screenshots to documentation
- [x] Update PROJECT_STATUS.md (this file)
- [x] Update CLI_PROJECT_STATUS.md
- [ ] Verify all Phase exit criteria are met
- [ ] Check for any remaining TODOs in code

**Test checklist (Phase 9)**
- [ ] README is clear and complete
- [ ] CLI documentation is comprehensive
- [ ] No blocking issues remain

**Exit criteria:** Project is documented and ready for use.

---

## What needs to be decided
1. ~~Maximum tasks per day limit (if any)~~ - Decision: No limit for MVP
2. ~~Default placeholder text for hidden notes~~ - Decision: "Add notes..."
3. ~~Keyboard shortcuts for CLI commands~~ - Decision: Not needed for MVP
4. ~~Whether to support markdown in hidden text area~~ - Decision: Plain text for MVP

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
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## Build Artifacts
| Platform | Path | Size |
|----------|------|------|
| macOS App | `app/build/macos/Build/Products/Release/daily_postit.app` | 42.5 MB |
| iOS Simulator | `app/build/ios/iphonesimulator/Runner.app` | ~30 MB |
| Go CLI | `bin/daily` | 6 MB |
