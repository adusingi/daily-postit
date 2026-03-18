package main

import (
	"fmt"
	"os"

	"github.com/dailypostit/cli/internal/commands"
)

// Command interface for all subcommands
type Command interface {
	Name() string
	InitFlags(args []string) error
	Run() error
}

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(0)
	}

	cmdName := os.Args[1]
	args := os.Args[2:]

	var cmd Command

	switch cmdName {
	case "list":
		cmd = commands.NewListCommand()
	case "add":
		cmd = commands.NewAddCommand()
	case "done":
		cmd = commands.NewDoneCommand()
	case "undone":
		cmd = commands.NewUndoneCommand()
	case "stats":
		cmd = commands.NewStatsCommand()
	case "help", "--help", "-h":
		printUsage()
		os.Exit(0)
	default:
		fmt.Fprintf(os.Stderr, "Unknown command: %s\n\n", cmdName)
		printUsage()
		os.Exit(1)
	}

	if err := cmd.InitFlags(args); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println("Daily Post-it CLI")
	fmt.Println("")
	fmt.Println("Usage:")
	fmt.Println("  daily list                   - Show today's unfinished tasks")
	fmt.Println("  daily list --done            - Show today's completed tasks")
	fmt.Println("  daily list --date 2026-03-15 - Show tasks for specific date")
	fmt.Println("  daily add \"Task content\"     - Add new task for today")
	fmt.Println("  daily done <task-id>         - Mark task as done")
	fmt.Println("  daily undone <task-id>       - Mark task as not done")
	fmt.Println("  daily stats                  - Show weekly completion rate")
	fmt.Println("")
}
