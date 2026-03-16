package commands

import (
	"flag"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/dailypostit/cli/internal/db"
	"github.com/dailypostit/cli/internal/models"
)

// AddCommand handles the add subcommand
type AddCommand struct {
	fs *flag.FlagSet

	content string
}

// NewAddCommand creates a new add command
func NewAddCommand() *AddCommand {
	cmd := &AddCommand{
		fs: flag.NewFlagSet("add", flag.ExitOnError),
	}
	return cmd
}

// Name returns the command name
func (c *AddCommand) Name() string {
	return c.fs.Name()
}

// InitFlags initializes the command flags
func (c *AddCommand) InitFlags(args []string) error {
	if err := c.fs.Parse(args); err != nil {
		return err
	}

	// Get remaining args as content
	remaining := c.fs.Args()
	if len(remaining) == 0 {
		fmt.Fprintf(os.Stderr, "Usage: daily add \"Task content\"\n")
		os.Exit(1)
	}

	c.content = strings.Join(remaining, " ")
	return nil
}

// Run executes the add command
func (c *AddCommand) Run() error {
	database, err := db.New()
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}
	defer database.Close()

	now := time.Now()
	task := &models.Task{
		Content:   c.content,
		Date:      now.Format("2006-01-02"),
		IsDone:    false,
		CreatedAt: now,
		UpdatedAt: now,
	}

	id, err := database.CreateTask(task)
	if err != nil {
		return fmt.Errorf("failed to create task: %w", err)
	}

	fmt.Printf("Added task #%d: %s\n\n", id, c.content)
	return nil
}
