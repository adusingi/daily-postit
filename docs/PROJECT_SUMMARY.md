---
title: "Daily Post-it - Project Summary"
---

# Daily Post-it - Project Summary

**Last Updated:** 2026-03-18  
**Status:** MVP Complete ✅

## Project overview
Daily Post-it is a minimalist daily todo app with CLI companion for macOS, iOS, and iPadOS:
- Clean task management for each day
- Binary task states (Done / Not Done) with hidden expandable notes
- Auto-rollover of unfinished tasks to new day
- CLI tool for macOS power users (written in Go)
- Firestore sync for GUI; SQLite retained for CLI and migration
- No authentication required
- Google sign-in with Firebase sync (macOS/iOS)

## Core MVP features
- Daily task list with today's date prominently displayed
- Add tasks via simple dialog (markdown parsing deferred)
- Binary task states: Done or Not Done (no progress percentages)
- Checkbox to toggle status with visual strikethrough when done
- Hidden attached text (notes/details) that stays collapsed by default
- Tap to expand/collapse the hidden text area
- Auto-rollover: unfinished tasks move to new day at midnight
- Completed tasks stay on original day (archived view)
- Simple date navigation to view previous days (read-only)
- Past days listed as collapsible rows under Today (tasks hidden until expanded)
- Google sign-in and cross-device sync via Firebase

## CLI Features (macOS only) ✅
- `daily list` — show today's unfinished tasks
- `daily list --done` — show today's completed tasks
- `daily list --date 2026-03-15` — show tasks for specific date
- `daily add "Task content"` — add new task for today
- `daily done <task-id>` — mark task as done
- `daily undone <task-id>` — mark task as not done
- `daily stats` — show completion rate for current week

**CLI Implementation:** Go (see `cli/` directory)
- Binary size: 6MB (optimized)
- Pure Go SQLite driver (no CGO)
- Standalone executable (no runtime dependencies)

## Technical stack
- **Framework:** Flutter (latest stable)
- **Targets:** macOS, iOS, iPadOS
- **Packages:**
  - `sqflite` - SQLite database
  - `firebase_core` - Firebase initialization
  - `firebase_auth` - Google sign-in
  - `cloud_firestore` - Cloud sync
  - `google_sign_in` - Google auth provider
  - `intl` - Date formatting
  - `path_provider` - Platform-specific paths
  - `shared_preferences` - Rollover tracking
  - `args` - CLI argument parsing (Dart CLI, deprecated)
- **CLI Language:** Go 1.22+
- **CLI SQLite:** modernc.org/sqlite (pure Go)
- **Database:** Firebase Firestore (GUI), SQLite (CLI + migration)
- **Database Location:** 
  - Firestore (cloud) for GUI sync
  - Local SQLite for CLI/migration:
    - macOS: `~/Library/Application Support/DailyPostIt/tasks.db`
    - iOS: App documents directory

## UI Requirements ✅
- Clean, distraction-free interface (Apple Notes aesthetic)
- Native macOS window controls
- iOS/iPadOS full-screen optimized
- Light/dark mode support via Material 3
- Smooth animations for checkbox toggles and hidden text expand/collapse

## Design system

### Color Palette
| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#007AFF` | Primary actions, checkboxes |
| `primary-hover` | `#0056B3` | Hover states for primary actions |
| `surface` | `#FFFFFF` | Card and frame surfaces |
| `surface-secondary` | `#F5F5F7` | Background, secondary surfaces |
| `text-primary` | `#1D1D1F` | Main text and headings |
| `text-secondary` | `#86868B` | Secondary text, timestamps |
| `text-muted` | `#A1A1A6` | Placeholder text |
| `border` | `#D2D2D7` | Borders and subtle separators |
| `success` | `#34C759` | Completed tasks, success states |
| `success-bg` | `#E8F5E9` | Completed task background |
| `divider` | `#E5E5EA` | List dividers |

### Typography
| Role | Font Family | Variable | Usage |
|------|-------------|----------|-------|
| **Date Header** | SF Pro Display | `font-date` | Today's date display |
| **Task Content** | SF Pro Text | `font-body` | Task text, notes |
| **Caption** | SF Pro Text | `font-caption` | Timestamps, metadata |

### UI Standards
- **Cards:**
  - Radius: `rounded-12`
  - Shadow: `0 1px 3px rgba(0,0,0,0.1)`
  - Padding: `16px`
- **Checkboxes:**
  - Size: `24x24`
  - Border radius: `6px`
  - Animation: 200ms ease-out scale + color
- **Task Item:**
  - Min height: `48px`
  - Padding: `12px 16px`
  - Divider: `1px solid divider`
- **Hidden Text:**
  - Animation: 250ms ease-in-out height transition
  - Background: `surface-secondary`
  - Border radius: `8px`

## File Structure
```
app/
├── lib/
│   ├── main.dart                # GUI entry point
│   ├── cli.dart                 # Dart CLI (deprecated, use Go CLI)
│   ├── models/
│   │   └── task.dart            # Task model
│   ├── screens/
│   │   ├── home_screen.dart     # Main home screen with date navigation
│   │   └── day_view.dart        # Individual day view with task list
│   ├── widgets/
│   │   └── task_item.dart       # Individual task item with checkbox
│   ├── services/
│   │   ├── database_service.dart # Shared SQLite logic
│   │   └── rollover_service.dart # Auto-rollover logic
│   └── utils/
│       └── database_path.dart   # Platform-specific db paths
├── macos/                       # macOS host
├── ios/                         # iOS host
├── assets/
├── test/
└── pubspec.yaml

cli/                               # Go CLI project
├── cmd/daily/
│   └── main.go                  # CLI entry point
├── internal/
│   ├── commands/
│   │   ├── list.go
│   │   ├── add.go
│   │   ├── done.go
│   │   ├── undone.go
│   │   └── stats.go
│   ├── db/
│   │   └── db.go
│   └── models/
│       └── task.go
├── Makefile
├── go.mod
└── go.sum

bin/
└── daily                        # Compiled Go CLI binary (generated by `make build`)

docs/                             # Product and status docs
```

## Database Schema
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL,
  date TEXT NOT NULL,           -- YYYY-MM-DD
  is_done INTEGER DEFAULT 0,   -- 0 or 1
  hidden_text TEXT,             -- Optional notes, stored collapsed
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE INDEX idx_tasks_date ON tasks(date);
CREATE INDEX idx_tasks_date_is_done ON tasks(date, is_done);
```

## Build Artifacts

| Platform | Path | Size |
|----------|------|------|
| macOS App | `app/build/macos/Build/Products/Release/daily_postit.app` | 42.5 MB |
| iOS Simulator | `app/build/ios/iphonesimulator/Runner.app` | ~30 MB |
| Go CLI | `bin/daily` | 6 MB |

## Decisions (Resolved)
| Decision | Resolution |
|----------|------------|
| CLI Language | Go (instead of Dart) for standalone binary |
| Markdown Editor | Deferred - using simple add dialog instead |
| Hidden text placeholder | "Add notes..." |
| Max tasks per day | No limit for MVP |
| CLI shortcuts | Not needed for MVP |
| Markdown in hidden text | Plain text for MVP |

## Usage

### GUI
```bash
cd app
flutter pub get
flutter run -d macos
flutter run -d ios
```

### CLI
```bash
# Build CLI
cd cli
make build
cd ..

# Add tasks
./bin/daily add "Buy milk"
./bin/daily add "Call mom"

# List tasks
./bin/daily list
./bin/daily list --done
./bin/daily list --date 2026-03-15

# Mark done/undone
./bin/daily done 1
./bin/daily undone 1

# Stats
./bin/daily stats
```
