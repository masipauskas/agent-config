# Project Name

## What This Is

One-liner description.

## Stack

Go 1.22+, golangci-lint, go test.

## Structure

```
cmd/        # Entrypoints
internal/   # Private packages
pkg/        # Public packages (if any)
```

## Setup

After copying this template:
- Create justfile for task running (test, lint, build targets)
- Add .lefthook.yml for pre-commit/pre-push hooks

## Conventions

- Table-driven tests with subtests.
- Error wrapping: fmt.Errorf("context: %w", err).
- No global state. Explicit dependency passing.
