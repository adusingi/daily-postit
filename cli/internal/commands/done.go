package commands

import (
	"flag"
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/dailypostit/cli/internal/db"
)

// DoneCommand handles the done subcommand
type DoneCommand struct {
	fs *flag.FlagSet

	taskID int
}

// NewDoneCommand creates a new done command
func NewDoneCommand() *DoneCommand {
	cmd := &DoneCommand{
		fs: flag.NewFlagSet("done", flag.ExitOnError),
	}
	return cmd
}

// Name returns the command name
func (c *DoneCommand) Name() string {
	return c.fs.Name()
}

// InitFlags initializes the command flags
func (c *DoneCommand) InitFlags(args []string) error {
	if err := c.fs.Parse(args); err != nil {
		return err
	}

	// Get remaining args as task ID
	remaining := c.fs.Args()
	if len(remaining) == 0 {
		fmt.Fprintf(os.Stderr, "Usage: daily done <task-id>\n")
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

// Run executes the done command
func (c *DoneCommand) Run() error {
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

	task.IsDone = true
	task.UpdatedAt = time.Now()

	if err := database.UpdateTask(task); err != nil {
		return fmt.Errorf("failed to update task: %w", err)
	}

	fmt.Printf("Task marked as done: %s\n\n", task.Content)
	return nil
}
