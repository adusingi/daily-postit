# Daily Post-it

A minimalist daily todo app with CLI companion for macOS, iOS, and iPadOS.

## Features

- Clean markdown-based task management for each day
- Binary task states (Done / Not Done) with hidden expandable notes
- Auto-rollover of unfinished tasks to new day
- CLI tool for macOS power users
- Shared SQLite database between GUI and CLI
- No authentication required

## Getting Started

### Prerequisites

- Flutter SDK (3.29.0+)
- macOS 11.0+ or iOS 15.0+

### Installation

```bash
cd app
flutter pub get
flutter run -d macos
```

The app will prompt for Google sign-in to enable cross-device sync.

### Firebase Setup (Local)

This repo stores a placeholder `app/lib/firebase_options.dart` to keep CI green
without committing real API keys. Generate real Firebase config locally:

```bash
cd app
flutterfire configure --project=daily-postit-89948
```

This generates (do not commit the real values):
- `app/firebase.json`
- `app/lib/firebase_options.dart` (overwrites the placeholder locally)
- `app/ios/Runner/GoogleService-Info.plist`
- `app/macos/Runner/GoogleService-Info.plist`

### CLI Usage

```bash
# Show today's tasks
daily list

# Add a new task
daily add "Buy groceries"

# Mark task as done
daily done 1

# Show weekly stats
daily stats
```

## Development

### Directory Structure

```
app/
└── lib/
    ├── main.dart                    # GUI entry point
    ├── cli.dart                     # CLI entry point
    ├── models/
    │   └── task.dart                # Task model
    ├── screens/
    │   ├── home_screen.dart         # Main home screen
    │   └── day_view.dart            # Day view
    ├── widgets/
    │   ├── markdown_editor.dart     # Markdown editor
    │   ├── task_item.dart           # Task item widget
    │   └── date_header.dart         # Date header
    ├── services/
    │   ├── database_service.dart    # Shared SQLite logic
    │   └── cli_service.dart         # CLI handlers
    └── utils/
        └── database_path.dart       # Platform-specific paths
cli/
└── ...                              # Go CLI project
docs/
└── ...                              # Project docs
```

### Database Location

- **macOS:** `~/Library/Application Support/DailyPostIt/tasks.db`
- **iOS:** App documents directory

## License

MIT License
