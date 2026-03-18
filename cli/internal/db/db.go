package db

import (
	"database/sql"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/dailypostit/cli/internal/models"
	_ "modernc.org/sqlite"
)

// DB wraps the sql.DB connection
type DB struct {
	conn *sql.DB
}

// New creates a new database connection
func New() (*DB, error) {
	dbPath, err := getDatabasePath()
	if err != nil {
		return nil, fmt.Errorf("failed to get database path: %w", err)
	}

	// Ensure directory exists
	dir := filepath.Dir(dbPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return nil, fmt.Errorf("failed to create database directory: %w", err)
	}

	conn, err := sql.Open("sqlite", dbPath)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Test connection
	if err := conn.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	db := &DB{conn: conn}

	// Initialize schema if needed
	if err := db.initSchema(); err != nil {
		return nil, fmt.Errorf("failed to initialize schema: %w", err)
	}

	return db, nil
}

// initSchema creates the database tables if they don't exist
func (db *DB) initSchema() error {
	query := `
		CREATE TABLE IF NOT EXISTS tasks (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			content TEXT NOT NULL,
			date TEXT NOT NULL,
			is_done INTEGER DEFAULT 0,
			hidden_text TEXT,
			created_at TEXT NOT NULL,
			updated_at TEXT NOT NULL
		)
	`
	if _, err := db.conn.Exec(query); err != nil {
		return fmt.Errorf("failed to create tasks table: %w", err)
	}

	// Create indexes
	if _, err := db.conn.Exec("CREATE INDEX IF NOT EXISTS idx_tasks_date ON tasks(date)"); err != nil {
		return fmt.Errorf("failed to create date index: %w", err)
	}
	if _, err := db.conn.Exec("CREATE INDEX IF NOT EXISTS idx_tasks_date_is_done ON tasks(date, is_done)"); err != nil {
		return fmt.Errorf("failed to create date_is_done index: %w", err)
	}

	return nil
}

// Close closes the database connection
func (db *DB) Close() error {
	return db.conn.Close()
}

// getDatabasePath returns the path to the SQLite database
// This matches the Flutter app's sandboxed database location
func getDatabasePath() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	
	// Check if sandboxed Flutter database exists
	sandboxedPath := filepath.Join(home, "Library", "Containers", "com.example.dailyPostit", "Data", "Library", "Application Support", "DailyPostIt", "tasks.db")
	if _, err := os.Stat(sandboxedPath); err == nil {
		return sandboxedPath, nil
	}
	
	// Fallback to non-sandboxed path
	return filepath.Join(home, "Library", "Application Support", "DailyPostIt", "tasks.db"), nil
}

// GetTasksForDate retrieves all tasks for a specific date
func (db *DB) GetTasksForDate(date string) ([]models.Task, error) {
	query := `
		SELECT id, content, date, is_done, hidden_text, created_at, updated_at
		FROM tasks
		WHERE date = ?
		ORDER BY created_at DESC
	`

	rows, err := db.conn.Query(query, date)
	if err != nil {
		return nil, fmt.Errorf("failed to query tasks: %w", err)
	}
	defer rows.Close()

	return scanTasks(rows)
}

// GetTaskByID retrieves a single task by ID
func (db *DB) GetTaskByID(id int) (*models.Task, error) {
	query := `
		SELECT id, content, date, is_done, hidden_text, created_at, updated_at
		FROM tasks
		WHERE id = ?
	`

	row := db.conn.QueryRow(query, id)
	task, err := scanTask(row)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to query task: %w", err)
	}

	return task, nil
}

// CreateTask inserts a new task into the database
func (db *DB) CreateTask(task *models.Task) (int64, error) {
	query := `
		INSERT INTO tasks (content, date, is_done, hidden_text, created_at, updated_at)
		VALUES (?, ?, ?, ?, ?, ?)
	`

	result, err := db.conn.Exec(
		query,
		task.Content,
		task.Date,
		boolToInt(task.IsDone),
		task.HiddenText,
		task.CreatedAt.Format(time.RFC3339),
		task.UpdatedAt.Format(time.RFC3339),
	)
	if err != nil {
		return 0, fmt.Errorf("failed to create task: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return 0, fmt.Errorf("failed to get last insert id: %w", err)
	}

	return id, nil
}

// UpdateTask updates an existing task
func (db *DB) UpdateTask(task *models.Task) error {
	query := `
		UPDATE tasks
		SET content = ?, date = ?, is_done = ?, hidden_text = ?, updated_at = ?
		WHERE id = ?
	`

	_, err := db.conn.Exec(
		query,
		task.Content,
		task.Date,
		boolToInt(task.IsDone),
		task.HiddenText,
		task.UpdatedAt.Format(time.RFC3339),
		task.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to update task: %w", err)
	}

	return nil
}

// DeleteTask removes a task from the database
func (db *DB) DeleteTask(id int) error {
	query := `DELETE FROM tasks WHERE id = ?`
	_, err := db.conn.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete task: %w", err)
	}
	return nil
}

// GetTasksForDateRange retrieves tasks within a date range
func (db *DB) GetTasksForDateRange(startDate, endDate string) ([]models.Task, error) {
	query := `
		SELECT id, content, date, is_done, hidden_text, created_at, updated_at
		FROM tasks
		WHERE date >= ? AND date <= ?
		ORDER BY date, created_at DESC
	`

	rows, err := db.conn.Query(query, startDate, endDate)
	if err != nil {
		return nil, fmt.Errorf("failed to query tasks: %w", err)
	}
	defer rows.Close()

	return scanTasks(rows)
}

// scanTasks scans multiple rows into Task structs
func scanTasks(rows *sql.Rows) ([]models.Task, error) {
	var tasks []models.Task
	for rows.Next() {
		var task models.Task
		var hiddenText sql.NullString
		var createdAt, updatedAt string

		err := rows.Scan(
			&task.ID,
			&task.Content,
			&task.Date,
			&task.IsDone,
			&hiddenText,
			&createdAt,
			&updatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan task: %w", err)
		}

		if hiddenText.Valid {
			task.HiddenText = &hiddenText.String
		}

		task.CreatedAt, _ = time.Parse(time.RFC3339, createdAt)
		task.UpdatedAt, _ = time.Parse(time.RFC3339, updatedAt)
		task.IsDone = task.IsDone // SQLite stores bool as int (0/1)

		tasks = append(tasks, task)
	}

	return tasks, rows.Err()
}

// scanTask scans a single row into a Task struct
type scanner interface {
	Scan(dest ...interface{}) error
}

func scanTask(row scanner) (*models.Task, error) {
	var task models.Task
	var hiddenText sql.NullString
	var createdAt, updatedAt string

	err := row.Scan(
		&task.ID,
		&task.Content,
		&task.Date,
		&task.IsDone,
		&hiddenText,
		&createdAt,
		&updatedAt,
	)
	if err != nil {
		return nil, err
	}

	if hiddenText.Valid {
		task.HiddenText = &hiddenText.String
	}

	task.CreatedAt, _ = time.Parse(time.RFC3339, createdAt)
	task.UpdatedAt, _ = time.Parse(time.RFC3339, updatedAt)

	return &task, nil
}

func boolToInt(b bool) int {
	if b {
		return 1
	}
	return 0
}
