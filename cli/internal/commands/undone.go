package commands

import (
	"flag"
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/dailypostit/cli/internal/db"
)

// UndoneCommand handles the undone subcommand
type UndoneCommand struct {
	fs *flag.FlagSet

	taskID int
}

// NewUndoneCommand creates a new undone command
func NewUndoneCommand() *UndoneCommand {
	cmd := &UndoneCommand{
		fs: flag.NewFlagSet("undone", flag.ExitOnError),
	}
	return cmd
}

// Name returns the command name
func (c *UndoneCommand) Name() string {
	return c.fs.Name()
}

// InitFlags initializes the command flags
func (c *UndoneCommand) InitFlags(args []string) error {
	if err := c.fs.Parse(args); err != nil {
		return err
	}

	// Get remaining args as task ID
	remaining := c.fs.Args()
	if len(remaining) == 0 {
		fmt.Fprintf(os.Stderr, "Usage: daily undone <task-id>\n")
		os.Exit(1)
	}

	id, err := strconv.Atoi(remaining[0])
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: Invalid task ID. Must be a number.\n")
		os.Exit(1)
	}

	c.taskID = id
	return nil
}

// Run executes the undone command
func (c *UndoneCommand) Run() error {
	database, err := db.New()
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}
	defer database.Close()

	task, err := database.GetTaskByID(c.taskID)
	if err != nil {
		return fmt.Errorf("failed to get task: %w", err)
	}

	if task == nil {
		fmt.Fprintf(os.Stderr, "Error: Task #%d not found\n", c.taskID)
		os.Exit(1)
	}

	task.IsDone = false
	task.UpdatedAt = time.Now()

	if err := database.UpdateTask(task); err != nil {
		return fmt.Errorf("failed to update task: %w", err)
	}

	fmt.Printf("Task marked as not done: %s\n\n", task.Content)
	return nil
}
