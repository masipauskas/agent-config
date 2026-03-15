# spec.md — Build agent-config repository

## Goal

Create a git repository called `agent-config` that holds all personal AI
coding assistant configuration. It must work with both Claude Code CLI and
OpenAI Codex CLI. A single install script symlinks everything into the right
places. Project templates let me bootstrap new repos in seconds.

## Principles

- One source of truth for coding standards (`ai-instructions.md`), referenced
  by both tool-specific wrappers. Never duplicate standards across files.
- Minimal files, minimal lines. Every line must change model behaviour or it
  gets cut.
- Templates are starting points, not generators. Copy and edit by hand.
- Open-source repos are never modified — use gitignored overlay files only.

---

## Repository Structure

```
agent-config/
├── README.md
├── install.sh                          # Symlinks config into ~/.claude/ and ~/.codex/ (zsh)
├── uninstall.sh                        # Removes symlinks cleanly (zsh)
│
├── global/
│   ├── ai-instructions.md             # Tool-agnostic coding standards (THE source of truth)
│   ├── CLAUDE.md                      # Claude Code wrapper: @imports ai-instructions.md
│   ├── AGENTS.md                      # Codex wrapper: references ai-instructions.md
│   ├── settings.json                  # Claude Code global permissions
│   └── rules/                         # Always-on behavioural directives (start empty)
│       └── .gitkeep
│
├── codex/
│   └── config.toml                    # Codex CLI defaults
│
├── agents/                            # Claude Code subagents (symlinked to ~/.claude/agents/)
│   ├── code-reviewer.md
│   └── test-writer.md
│
└── templates/                         # Copy into project repos as starting points
    ├── python-project/
    │   ├── CLAUDE.md
    │   └── AGENTS.md
    ├── go-project/
    │   ├── CLAUDE.md
    │   └── AGENTS.md
    └── oss-contrib/
        └── CLAUDE.local.md            # Gitignored overlay for OSS repos
```

---

## File Specifications

### global/ai-instructions.md

Tool-agnostic coding standards. No mention of Claude, Codex, or any specific
tool. Any LLM can consume this. Contents (use these exactly):

```markdown
# Coding Standards

## Code Style

Boring, explicit, linear code. A reader follows any function top to bottom.

Pure functions for transformations. Dataclasses for domain objects, with methods
for behaviour that belongs to them. OOP classes only for external system
interfaces (broker adapters, API clients, DB connections).

Single-purpose functions. No flag parameters that switch logic paths.
Early returns over nested conditionals. Never mutate inputs or global state.

Extract shared code at the third instance, not before. Check if logic already
exists before writing new code.

All imports at top of file. Comments in English.

## Types

Strict types on all signatures, returns, variables, and collections.
No Any, unknown, or Dict[str, Any]. Structured models (dataclasses, TypedDict,
Pydantic) over loose dicts.

Explicit parameters for public/domain functions — avoid defaults that hide
caller intent. Obvious defaults on internal helpers are fine.

## Errors

Raise explicitly. Specific error types. No silent ignoring, no catch-all handlers,
no fallbacks unless asked. Fix causes, not symptoms.

Error messages include debug context: request params, response body, status codes.
External calls: retry with warnings, then raise last error.
Structured log fields, not string interpolation.

## Testing

Integration tests for real business flows. Unit tests only for complex logic
(calculations, state transitions, parsers).

Descriptive names: test_position_closed_when_stop_loss_hit.
Real objects over mocks. In-memory fakes for external services.

## Documentation

Code is documentation. Clear naming, types, targeted docstrings.
Docstrings live on the function or class they describe.
No docstrings on obvious functions. No comments restating code.
No duplicated docs. Store knowledge as current state, not changelogs.

## Dependencies

Project-local environments. pyproject.toml / package.json / go.mod.
Read dependency source code instead of guessing behaviour.

## Tools

When uncertain about library APIs, use chub to fetch documentation:
`chub get <library>/api --lang <language>`. Fallback to reading installed
source code in local environment directories.

## Git

Conventional commits: type(scope): description
One logical change per commit. Never force push main.
```

### global/CLAUDE.md

Thin wrapper that imports the shared standards and adds Claude-specific workflow.

```markdown
@ai-instructions.md

## Workflow

Read existing code before editing. Keep changes minimal and on-task.
Match the repository's style, even when it differs from my preferences.
Inspect the codebase instead of inventing patterns.
Run project test/lint commands after changing code.
Use rg for code search. Non-interactive commands only.
```

### global/AGENTS.md

Thin wrapper for Codex CLI. Codex does not support @ imports, so it tells the
model to read the file. Also adds Codex-specific workflow (non-interactive git).

```markdown
Read ai-instructions.md in this directory for coding standards.

## Workflow

Inspect the repository before editing. Keep changes minimal and on-task.
Match the repository's style, even when it differs from my preferences.
Do not revert unrelated changes.
Use rg for code search. Non-interactive commands with flags.
Always: git --no-pager diff or git diff | cat.
Run project test/lint commands after changing code.
```

### global/settings.json

Claude Code global permissions. Allow safe read/build/test commands, deny
destructive operations.

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(just *)",
      "Bash(uv *)",
      "Bash(go build *)",
      "Bash(go test *)",
      "Bash(ruff *)",
      "Bash(mypy *)",
      "Bash(pytest *)",
      "Bash(golangci-lint *)",
      "Bash(gh *)",
      "Bash(ls *)",
      "Bash(cat *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(wc *)",
      "Bash(find *)",
      "Bash(grep *)",
      "Bash(rg *)",
      "Bash(fd *)",
      "Bash(chub *)"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(sudo *)"
    ]
  },
  "env": {
    "PYTHONDONTWRITEBYTECODE": "1"
  }
}
```

### codex/config.toml

Codex CLI defaults. Falls back to CLAUDE.md if no AGENTS.md is found.

```toml
model = "gpt-5.2-codex"
approval_mode = "suggest"
project_doc_max_bytes = 65536
project_doc_fallback_filenames = ["AGENTS.md", "CLAUDE.md"]
```

### agents/code-reviewer.md

Claude Code subagent. Read-only review. Uses Sonnet for speed/cost.

```markdown
---
name: code-reviewer
description: Reviews code changes for correctness, edge cases, and convention adherence
tools: Read, Glob, Grep, Bash
model: sonnet
---

Review recent changes. Be direct and specific.

Check for:
1. Logic errors and unhandled edge cases
2. Convention violations (read CLAUDE.md and surrounding code)
3. Missing error handling or silent failures
4. Test coverage gaps for changed behaviour
5. Unnecessary complexity or premature abstraction

Skip cosmetic issues the linter catches. If the code is good, say so briefly.
```

### agents/test-writer.md

Claude Code subagent. Writes and runs tests. Uses Sonnet.

```markdown
---
name: test-writer
description: Writes integration and unit tests for recent code changes
tools: Read, Write, Edit, Glob, Grep, Bash
model: sonnet
---

Write tests for recent changes. Prefer integration tests.

Rules:
1. Test business behaviour, not implementation details.
2. Descriptive names: test_expired_position_gets_closed_at_next_cycle
3. Real objects over mocks. In-memory fakes for external services.
4. Cover the happy path and important failure modes.
5. No shared mutable state between tests.
6. Run the tests after writing them.
```

---

## Template Specifications

Templates are starting-point files copied into project repos. They contain
placeholder text (like "Project Name", "One-liner description") that the user
edits after copying.

### templates/python-project/CLAUDE.md

```markdown
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
```

### templates/python-project/AGENTS.md

Codex project-level wrapper. Same pattern as global: reference the standards,
add project specifics.

```markdown
Read the project CLAUDE.md for architecture and conventions.
Read ai-instructions.md (in ~/.codex/ or project root) for coding standards.

Check the project justfile for available commands (test, lint, format).
```

### templates/go-project/CLAUDE.md

```markdown
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
```

### templates/go-project/AGENTS.md

```markdown
Read the project CLAUDE.md for architecture and conventions.

Check the project justfile for available commands (test, lint, build).
```

### templates/oss-contrib/CLAUDE.local.md

For contributing to open-source repos. Gitignored. Does not modify their repo.

```markdown
# Personal context for this repo

## My focus areas

- Packages I work in: (edit this)
- Build: (check their Makefile / mage / scripts)
- Test: (their test command here)

## Approach

Follow existing project conventions. Read surrounding code first.
My global preferences apply only where they don't conflict with
the project's established patterns.

## Current work

- gh issue list --assignee @me
```

---

## install.sh Specification

Zsh script with shebang `#!/usr/bin/env zsh`. Use `set -euo pipefail`. Does the following:

1. Creates directories: `~/.claude/{agents,rules}`, `~/.codex/`
2. Symlinks into `~/.claude/`:
   - `global/CLAUDE.md` → `~/.claude/CLAUDE.md`
   - `global/ai-instructions.md` → `~/.claude/ai-instructions.md`
   - `global/settings.json` → `~/.claude/settings.json`
   - Each file in `agents/*.md` → `~/.claude/agents/<filename>`
   - Each file in `global/rules/*.md` → `~/.claude/rules/<filename>` (if any exist)
3. Symlinks into `~/.codex/`:
   - `global/AGENTS.md` → `~/.codex/AGENTS.md`
   - `global/ai-instructions.md` → `~/.codex/ai-instructions.md`
4. Copies `codex/config.toml` → `~/.codex/config.toml` only if it doesn't
   already exist (don't overwrite user edits)
5. Prints what it did. No sudo, no brew, no package installs.

Use `ln -sf` (force, symbolic) for all symlinks so re-running is idempotent.

## uninstall.sh Specification

Zsh script with shebang `#!/usr/bin/env zsh`. Removes only the symlinks that point back into this repo.
Does NOT delete ~/.claude/ or ~/.codex/ directories. Does NOT remove files
that aren't symlinks to this repo (protects user modifications).

Logic: for each expected symlink target, check if it's a symlink pointing
to $REPO_DIR/..., and only then remove it.

---

## README.md Specification

Short. Covers:
1. What this repo is (one sentence)
2. The file layout (tree diagram)
3. Install instructions (`./install.sh`)
4. Per-project setup (copy template, edit CLAUDE.md)
5. How the merge order works (Claude Code and Codex)
6. Where project-specific agents/skills go (in the project repo, not here)

No badges, no contributing guide, no license section. This is a personal repo.

---

## Verification

After building, verify:

1. `./install.sh` runs cleanly and is idempotent (run twice, no errors)
2. `./uninstall.sh` removes only its own symlinks
3. `ls -la ~/.claude/CLAUDE.md` shows symlink to this repo
4. `ls -la ~/.codex/AGENTS.md` shows symlink to this repo
5. `cat ~/.claude/CLAUDE.md` shows the @ai-instructions.md import line
6. `cat ~/.codex/AGENTS.md` shows the reference to ai-instructions.md
7. All template files contain placeholder text, not real project data
8. Template CLAUDE.md files mention setting up justfile and lefthook
9. `global/rules/` contains only `.gitkeep`
10. `git init && git add -A && git status` shows a clean set of files

---

## What This Repo Does NOT Contain

- Project-specific CLAUDE.md files (those live in project repos)
- MCP server configuration (connect per-session with `claude mcp add`)
- Skills or plugins (build in project repos when needed, not before)
- CI/CD configuration (this repo doesn't need CI)
- Any generated or compiled output
