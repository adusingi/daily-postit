.PHONY: build clean test install deps run

BINARY_NAME=daily
BUILD_DIR=../bin
GO=go

# Build the CLI binary
build:
	cd .. && $(GO) -C cli build -o $(BUILD_DIR)/$(BINARY_NAME) ./cmd/daily

# Build for production (optimized)
build-prod:
	cd .. && $(GO) -C cli build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME) ./cmd/daily

# Download dependencies
deps:
	cd .. && $(GO) -C cli mod download
	cd .. && $(GO) -C cli mod tidy

# Run the CLI (for testing)
run:
	cd .. && $(GO) -C cli run ./cmd/daily $(ARGS)

# Clean build artifacts
clean:
	rm -f $(BUILD_DIR)/$(BINARY_NAME)

# Run tests
test:
	cd .. && $(GO) -C cli test ./...

# Install locally (requires ~/bin in PATH)
install: build
	cp $(BUILD_DIR)/$(BINARY_NAME) ~/bin/$(BINARY_NAME)

# Format code
fmt:
	cd .. && $(GO) -C cli fmt ./...

# Run linter
lint:
	cd .. && $(GO) -C cli vet ./...
