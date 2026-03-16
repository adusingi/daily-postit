---
title: "Daily Post-it - CLI Project Status"
---

# Daily Post-it - CLI Project Status

**Last Updated:** 2026-03-16
**Current Phase:** CLI Implementation
**Branch Policy:** Work on `main`, create feature branches for CLI features.

---

## Phase 1: CLI Command Structure (Target: Day 1)
**Objective:** Implement CLI command parsing and entry point.

**Task checklist (Phase 1)**
- [x] Create CLI entry point (`bin/daily_cli.dart`)
- [x] Set up argument parsing with `args` package
- [x] Implement `daily list` command
- [x] Implement `daily list --done` flag
- [x] Implement `daily list --date YYYY-MM-DD` flag
- [x] Implement `daily add "Task content"` command
- [x] Implement `daily done <task-id>` command
- [x] Implement `daily undone <task-id>` command
- [x] Implement `daily stats` command
- [x] Add help/usage message

**Test checklist (Phase 1)**
- [x] `daily` without arguments shows help
- [x] `daily list` command syntax works
- [x] `daily add` command syntax works
- [x] `daily done` command syntax works
- [x] `daily undone` command syntax works
- [x] `daily stats` command syntax works

**Exit criteria:** CLI commands parsed correctly with proper error handling.

---

## Phase 2: CLI Database Integration (Target: Day 1-2)
**Objective:** Connect CLI to shared SQLite database.

**Task checklist (Phase 2)**
- [x] Import database service into CLI
- [x] Configure database path resolution for CLI
- [ ] Implement `list` command with database query
- [ ] Implement `add` command with database insert
- [ ] Implement `done` command with database update
- [ ] Implement `undone` command with database update
- [ ] Implement `stats` command with date range query
- [ ] Add error handling for database operations

**Test checklist (Phase 2)**
- [ ] CLI can read from shared database
- [ ] CLI can write to shared database
- [ ] CLI and GUI use same database file
- [ ] CLI handles missing database gracefully

**Exit criteria:** CLI reads and writes to shared SQLite database successfully.

---

## Phase 3: CLI Output Formatting (Target: Day 2)
**Objective:** Format CLI output for readability.

**Task checklist (Phase 3)**
- [ ] Format list output with checkboxes and IDs
- [ ] Show task dates in user-friendly format
- [ ] Include hidden notes when present
- [ ] Color code output (optional)
- [ ] Format stats output clearly

**Test checklist (Phase 3)**
- [ ] List output is easy to read
- [ ] Task IDs are visible for done/undone commands
- [ ] Stats output shows completion percentage
- [ ] Error messages are user-friendly

**Exit criteria:** CLI output is clear and user-friendly.

---

## Phase 4: CLI Error Handling (Target: Day 2)
**Objective:** Handle edge cases and errors gracefully.

**Task checklist (Phase 4)**
- [ ] Handle invalid task IDs
- [ ] Handle missing date format
- [ ] Handle empty task lists
- [ ] Handle database errors
- [ ] Provide helpful error messages

**Test checklist (Phase 4)**
- [ ] Invalid ID shows clear error message
- [ ] Invalid date format shows error
- [ ] Empty list shows appropriate message
- [ ] Database errors are handled gracefully

**Exit criteria:** CLI handles all error cases gracefully with clear messages.

---

## Phase 5: Build CLI Executable (Target: Day 2-3)
**Objective:** Create standalone CLI executable.

**Task checklist (Phase 5)**
- [ ] Configure build script for CLI
- [ ] Compile CLI to standalone executable
- [ ] Test executable without Flutter SDK
- [ ] Add executable to PATH (optional)

**Test checklist (Phase 5)**
- [ ] Executable runs without Flutter SDK
- [ ] Executable works with compiled app
- [ ] Executable works with CLI from source

**Exit criteria:** Standalone CLI executable works without Flutter SDK.

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
```
