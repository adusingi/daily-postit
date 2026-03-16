---
title: "Daily Post-it - Project Summary"
---

# Daily Post-it - Project Summary

## Project overview
Daily Post-it is a minimalist daily todo app with CLI companion for macOS, iOS, and iPadOS:
- Clean markdown-based task management for each day
- Binary task states (Done / Not Done) with hidden expandable notes
- Auto-rollover of unfinished tasks to new day
- CLI tool for macOS power users
- Shared SQLite database between GUI and CLI
- No authentication required

## Core MVP features
- Daily markdown text editor with today's date prominently displayed
- Parse markdown bullet points (`- task` or `* task`) into todo items automatically
- Support simple markdown: bold, italic, bullet lists
- Binary task states: Done or Not Done (no progress percentages)
- Checkbox to toggle status with visual strikethrough when done
- Hidden attached text (notes/details) that stays collapsed by default
- Tap to expand/collapse the hidden text area
- Auto-rollover: unfinished tasks move to new day at midnight
- Completed tasks stay on original day (archived view)
- Simple date navigation to view previous days (read-only)

## CLI Features (macOS only)
- `daily list` — show today's unfinished tasks
- `daily list --done` — show today's completed tasks
- `daily list --date 2026-03-15` — show tasks for specific date
- `daily add "Task content"` — add new task for today
- `daily done <task-id>` — mark task as done
- `daily undone <task-id>` — mark task as not done
- `daily stats` — show completion rate for current week

## Technical stack
- **Framework:** Flutter (latest stable)
- **Targets:** macOS, iOS, iPadOS
- **Packages:**
  - `sqflite` - SQLite database
  - `flutter_markdown` - Markdown rendering
  - `intl` - Date formatting
  - `args` - CLI argument parsing
  - `path_provider` - Platform-specific paths
- **Database:** SQLite shared between GUI and CLI
- **Database Location:** 
  - macOS: `~/Library/Application Support/DailyPostIt/tasks.db`
  - iOS: App documents directory

## UI Requirements
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
lib/
├── main.dart                    # GUI entry point
├── cli.dart                     # CLI entry point
├── models/
│   └── task.dart                # Task model
├── screens/
│   ├── home_screen.dart         # Main home screen with date navigation
│   └── day_view.dart            # Individual day view with editor
├── widgets/
│   ├── markdown_editor.dart     # Markdown text editor widget
│   ├── task_item.dart           # Individual task item with checkbox
│   └── date_header.dart         # Date display header
├── services/
│   ├── database_service.dart     # Shared SQLite logic
│   └── cli_service.dart         # CLI command handlers
└── utils/
    └── database_path.dart        # Platform-specific db paths
bin/
└── daily_cli.dart                # CLI executable wrapper
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

## Open decisions
- Keyboard shortcuts for CLI (e.g., `d` for `done`, `u` for `undone`)
- Default hidden text placeholder text
- Maximum tasks per day limit (if any)
- Whether to support markdown in hidden text area
