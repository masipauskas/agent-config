# Project Name

## What This Is

One-liner description.

## Stack

Python 3.12+, polars, uv, pytest, ruff, mypy.

## Structure

```
src/
  core/       # Domain types, state
  ...
tests/
  integration/
  unit/
```

## Setup

After copying this template:
- Create justfile for task running (test, lint, format targets)
- Add .lefthook.yml for pre-commit/pre-push hooks
- Run `uv sync` to install dependencies

## Conventions

- Polars, not pandas.
- Decimal for money/prices, never float.
- State as parquet or SQLite. No external DB unless needed.
