package commands

import (
	"flag"
	"fmt"
	"time"

	"github.com/dailypostit/cli/internal/db"
)

// StatsCommand handles the stats subcommand
type StatsCommand struct {
	fs *flag.FlagSet
}

// NewStatsCommand creates a new stats command
func NewStatsCommand() *StatsCommand {
	cmd := &StatsCommand{
		fs: flag.NewFlagSet("stats", flag.ExitOnError),
	}
	return cmd
}

// Name returns the command name
func (c *StatsCommand) Name() string {
	return c.fs.Name()
}

// InitFlags initializes the command flags
func (c *StatsCommand) InitFlags(args []string) error {
	return c.fs.Parse(args)
}

// Run executes the stats command
func (c *StatsCommand) Run() error {
	database, err := db.New()
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}
	defer database.Close()

	now := time.Now()
	// Get start of week (Monday)
	weekday := int(now.Weekday())
	if weekday == 0 {
		weekday = 7 // Sunday = 7
	}
	startOfWeek := now.AddDate(0, 0, -(weekday - 1))

	startDate := startOfWeek.Format("2006-01-02")
	endDate := now.Format("2006-01-02")

	tasks, err := database.GetTasksForDateRange(startDate, endDate)
	if err != nil {
		return fmt.Errorf("failed to get tasks: %w", err)
	}

	// Calculate stats
	total := len(tasks)
	done := 0
	for _, task := range tasks {
		if task.IsDone {
			done++
		}
	}

	// Calculate percentage
	var percentage float64
	if total > 0 {
		percentage = float64(done) / float64(total) * 100
	}

	// Print stats
	fmt.Println("\nWeekly Stats:")
	fmt.Println()
	fmt.Printf("  Period: %s - %s\n",
		startOfWeek.Format("Jan 2"),
		now.Format("Jan 2, 2006"))
	fmt.Println()
	fmt.Printf("  Total tasks:    %d\n", total)
	fmt.Printf("  Completed:      %d\n", done)
	fmt.Printf("  Completion:     %.1f%%\n", percentage)
	fmt.Println()

	return nil
}
