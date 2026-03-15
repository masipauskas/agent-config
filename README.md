# agent-config

Personal AI coding assistant configuration for Claude Code and OpenAI Codex CLI.

## Architecture

One source of truth: `global/ai-instructions.md` holds all coding standards. Both tool-specific wrappers (`CLAUDE.md`, `AGENTS.md`) reference it rather than duplicating it. Install symlinks everything into `~/.claude/` and `~/.codex/` so updates take effect immediately after `git pull`.

```
global/ai-instructions.md   ← coding standards (tool-agnostic)
       ↓                              ↓
global/CLAUDE.md            global/AGENTS.md
(@imports ai-instructions)  (tells model to read it)
       ↓                              ↓
~/.claude/CLAUDE.md         ~/.codex/AGENTS.md
```

## Layout

```
agent-config/
├── install.sh                          # Symlinks config into ~/.claude/ and ~/.codex/
├── uninstall.sh                        # Removes symlinks cleanly
│
├── global/
│   ├── ai-instructions.md             # Tool-agnostic coding standards (source of truth)
│   ├── CLAUDE.md                      # Claude Code wrapper: @imports ai-instructions.md
│   ├── AGENTS.md                      # Codex wrapper: references ai-instructions.md
│   ├── settings.json                  # Claude Code global permissions
│   └── rules/                         # Always-on behavioural directives (.md files)
│
├── codex/
│   └── config.toml                    # Codex CLI defaults (copied once, not symlinked)
│
├── agents/                            # Claude Code subagents (symlinked to ~/.claude/agents/)
│   ├── code-reviewer.md               # Read-only review: logic, conventions, test gaps
│   └── test-writer.md                 # Writes and runs integration + unit tests
│
└── templates/                         # Copy into project repos, then edit by hand
    ├── python-project/                # Python 3.12+, uv, polars, ruff, mypy
    ├── go-project/                    # Go 1.22+, golangci-lint
    └── oss-contrib/                   # CLAUDE.local.md overlay for OSS repos
```

## Install

```zsh
git clone <this-repo>
cd agent-config
./install.sh
```

Idempotent — safe to re-run after `git pull`.

## Per-project setup

1. Copy a template into your project: `cp -r templates/python-project/{CLAUDE.md,AGENTS.md} .`
2. Edit `CLAUDE.md`: fill in project name, description, stack, and structure
3. Commit it

For OSS repos: copy `templates/oss-contrib/CLAUDE.local.md` to the repo root and add `CLAUDE.local.md` to your global `.gitignore`. Never modify the upstream repo's files.

## How config layers work

**Claude Code** merges in order: `~/.claude/CLAUDE.md` → project `CLAUDE.md` → `CLAUDE.local.md`. Each layer adds context; later files can override earlier ones.

**Codex** reads `~/.codex/AGENTS.md`, then the project `AGENTS.md`. No `@`-import support, so each file explicitly tells the model where to find the standards.

## Subagents

Invoke with `claude /code-reviewer` or `claude /test-writer` inside any project.

To add project-specific agents, drop `.md` files into `.claude/agents/` in the project repo — they are picked up automatically and scoped to that project.

## Updating

```zsh
git pull
./install.sh   # symlinks already point here, but re-running picks up new agents/rules
```
