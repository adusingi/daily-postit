package commands

import (
	"flag"
	"fmt"
	"os"
	"time"

	"github.com/dailypostit/cli/internal/db"
	"github.com/dailypostit/cli/internal/models"
)

// ListCommand handles the list subcommand
type ListCommand struct {
	fs *flag.FlagSet

	done bool
	date string
}

// NewListCommand creates a new list command
func NewListCommand() *ListCommand {
	cmd := &ListCommand{
		fs: flag.NewFlagSet("list", flag.ExitOnError),
	}
	cmd.fs.BoolVar(&cmd.done, "done", false, "Show completed tasks")
	cmd.fs.StringVar(&cmd.date, "date", "", "Show tasks for specific date (YYYY-MM-DD)")
	return cmd
}

// Name returns the command name
func (c *ListCommand) Name() string {
	return c.fs.Name()
}

// InitFlags initializes the command flags
func (c *ListCommand) InitFlags(args []string) error {
	return c.fs.Parse(args)
}

// Run executes the list command
func (c *ListCommand) Run() error {
	database, err := db.New()
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}
	defer database.Close()

	// Determine date
	date := c.date
	if date == "" {
		date = time.Now().Format("2006-01-02")
	}

	// Parse and validate date if provided
	if c.date != "" {
		parsedDate, err := time.Parse("2006-01-02", c.date)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: Invalid date format. Use YYYY-MM-DD\n")
			os.Exit(1)
		}
		date = parsedDate.Format("2006-01-02")
	}

	tasks, err := database.GetTasksForDate(date)
	if err != nil {
		return fmt.Errorf("failed to get tasks: %w", err)
	}

	// Filter by done status
	var filtered []models.Task
	for _, task := range tasks {
		if task.IsDone == c.done {
			filtered = append(filtered, task)
		}
	}

	// Format output
	dateLabel := date
	if c.date == "" {
		dateLabel = "today"
	}

	statusLabel := "unfinished"
	if c.done {
		statusLabel = "completed"
	}

	fmt.Printf("\nTasks for %s (%s):\n\n", dateLabel, statusLabel)

	if len(filtered) == 0 {
		fmt.Println("  No tasks found.")
		fmt.Println()
		return nil
	}

	for _, task := range filtered {
		fmt.Printf("  %s %d: %s\n", task.FormatStatus(), task.ID, task.Content)
		if task.HiddenText != nil && *task.HiddenText != "" {
			fmt.Printf("      Note: %s\n", *task.HiddenText)
		}
	}
	fmt.Println()

	return nil
}
