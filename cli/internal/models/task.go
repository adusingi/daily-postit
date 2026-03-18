package models

import "time"

// Task represents a daily todo item
type Task struct {
	ID          int
	Content     string
	Date        string // YYYY-MM-DD format
	IsDone      bool
	HiddenText  *string
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// FormatStatus returns a checkbox representation of the task status
func (t *Task) FormatStatus() string {
	if t.IsDone {
		return "[✓]"
	}
	return "[ ]"
}

// FormatDate returns a human-friendly date representation
func (t *Task) FormatDate() string {
	// Parse the stored date
	time, err := time.Parse("2006-01-02", t.Date)
	if err != nil {
		return t.Date
	}
	return time.Format("Monday, January 2, 2006")
}
