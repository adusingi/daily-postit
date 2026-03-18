---
title: "Daily Post-it - CLI Project Status"
---

# Daily Post-it - CLI Project Status

**Last Updated:** 2026-03-18
**Current Phase:** CLI Complete ✅
**Branch Policy:** Work on `development`, create feature branches for CLI features.

---

## Implementation Summary

The CLI has been re-implemented in **Go** (instead of Dart) for better performance and standalone executable support. The Go CLI is located in `cli/` and compiles to a native macOS binary.

### Why Go?
- Standalone executable (no Flutter/Dart runtime needed)
- Smaller binary size (6MB vs 40MB+)
- Faster startup time
- Better cross-compilation support
- Pure Go SQLite driver (no CGO)

---

## Phase 1: CLI Command Structure (Target: Day 1) ✅ COMPLETE
**Objective:** Implement CLI command parsing and entry point.

**Task checklist (Phase 1)**
- [x] Create Go CLI project structure (`cli/`)
- [x] Set up argument parsing with `flag` package
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

**Exit criteria:** CLI commands parsed correctly with proper error handling. ✅

---

## Phase 2: CLI Database Integration (Target: Day 1-2) ✅ COMPLETE
**Objective:** Connect CLI to shared SQLite database.

**Task checklist (Phase 2)**
- [x] Create Go database service (`cli/internal/db/db.go`)
- [x] Configure database path resolution for CLI (same as Flutter)
- [x] Implement `list` command with database query
- [x] Implement `add` command with database insert
- [x] Implement `done` command with database update
- [x] Implement `undone` command with database update
- [x] Implement `stats` command with date range query
- [x] Add error handling for database operations
- [x] Auto-initialize database schema if not exists

**Test checklist (Phase 2)**
- [x] CLI can read from shared database
- [x] CLI can write to shared database
- [x] CLI and GUI use same database file
- [x] CLI handles missing database gracefully

**Exit criteria:** CLI reads and writes to shared SQLite database successfully. ✅

---

## Phase 3: CLI Output Formatting (Target: Day 2) ✅ COMPLETE
**Objective:** Format CLI output for readability.

**Task checklist (Phase 3)**
- [x] Format list output with checkboxes and IDs
- [x] Show task dates in user-friendly format
- [x] Include hidden notes when present
- [x] Format stats output clearly

**Test checklist (Phase 3)**
- [x] List output is easy to read
- [x] Task IDs are visible for done/undone commands
- [x] Stats output shows completion percentage
- [x] Error messages are user-friendly

**Exit criteria:** CLI output is clear and user-friendly. ✅

---

## Phase 4: CLI Error Handling (Target: Day 2) ✅ COMPLETE
**Objective:** Handle edge cases and errors gracefully.

**Task checklist (Phase 4)**
- [x] Handle invalid task IDs
- [x] Handle missing date format
- [x] Handle empty task lists
- [x] Handle database errors
- [x] Provide helpful error messages

**Test checklist (Phase 4)**
- [x] Invalid ID shows clear error message
- [x] Invalid date format shows error
- [x] Empty list shows appropriate message
- [x] Database errors are handled gracefully

**Exit criteria:** CLI handles all error cases gracefully with clear messages. ✅

---

## Phase 5: Build CLI Executable (Target: Day 2-3) ✅ COMPLETE
**Objective:** Create standalone CLI executable.

**Task checklist (Phase 5)**
- [x] Create Makefile for building
- [x] Compile CLI to standalone executable
- [x] Test executable without Flutter SDK
- [x] Optimize binary with ldflags (6MB)

**Test checklist (Phase 5)**
- [x] Executable runs without Flutter SDK
- [x] Executable works with compiled app
- [x] Executable works with CLI from source

**Exit criteria:** Standalone CLI executable works without Flutter SDK. ✅

---

## File Structure

```
cli/
├── cmd/daily/
│   └── main.go              # CLI entry point
├── internal/
│   ├── db/
│   │   └── db.go            # SQLite connection & queries
│   ├── commands/
│   │   ├── list.go          # daily list [--done] [--date]
│   │   ├── add.go           # daily add "Task"
│   │   ├── done.go          # daily done <id>
│   │   ├── undone.go        # daily undone <id>
│   │   └── stats.go         # daily stats
│   └── models/
│       └── task.go          # Task struct
├── go.mod
├── go.sum
└── Makefile                 # Build commands
```

---

## Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| `daily list` | Show today's unfinished tasks | `daily list` |
| `daily list --done` | Show today's completed tasks | `daily list --done` |
| `daily list --date <date>` | Show tasks for specific date | `daily list --date 2026-03-15` |
| `daily add "<task>"` | Add new task for today | `daily add "Buy milk"` |
| `daily done <id>` | Mark task as done | `daily done 1` |
| `daily undone <id>` | Mark task as not done | `daily undone 1` |
| `daily stats` | Show weekly completion rate | `daily stats` |

---

## Build Instructions

```bash
# Build CLI
cd cli
make build

# Or build optimized version
cd cli
make build-prod

# Output: bin/daily (6MB) at repo root (generated)
```

---

## Dependencies

```go
// go.mod
require (
    modernc.org/sqlite v1.29.5  // Pure Go SQLite driver
)
```

---

## Testing

```bash
# Add tasks
./bin/daily add "Test task 1"
./bin/daily add "Test task 2"

# List tasks
./bin/daily list

# Mark done
./bin/daily done 1

# List completed
./bin/daily list --done

# Stats
./bin/daily stats
```
