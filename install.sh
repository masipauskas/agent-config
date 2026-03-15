#!/usr/bin/env zsh
set -euo pipefail

REPO_DIR=${0:A:h}

# Create directories
mkdir -p ~/.claude/agents ~/.claude/rules ~/.codex

# Symlink Claude Code globals
ln -sf "$REPO_DIR/global/CLAUDE.md"          ~/.claude/CLAUDE.md
ln -sf "$REPO_DIR/global/ai-instructions.md" ~/.claude/ai-instructions.md
ln -sf "$REPO_DIR/global/settings.json"      ~/.claude/settings.json
echo "Linked ~/.claude/{CLAUDE.md,ai-instructions.md,settings.json}"

# Symlink agents
for f in "$REPO_DIR"/agents/*.md; do
  ln -sf "$f" ~/.claude/agents/${f:t}
  echo "Linked ~/.claude/agents/${f:t}"
done

# Symlink rules (if any .md files exist)
for f in "$REPO_DIR"/global/rules/*.md(N); do
  ln -sf "$f" ~/.claude/rules/${f:t}
  echo "Linked ~/.claude/rules/${f:t}"
done

# Symlink Codex globals
ln -sf "$REPO_DIR/global/AGENTS.md"         ~/.codex/AGENTS.md
ln -sf "$REPO_DIR/global/ai-instructions.md" ~/.codex/ai-instructions.md
echo "Linked ~/.codex/{AGENTS.md,ai-instructions.md}"

# Copy codex config only if it doesn't already exist
if [[ ! -f ~/.codex/config.toml ]]; then
  cp "$REPO_DIR/codex/config.toml" ~/.codex/config.toml
  echo "Copied ~/.codex/config.toml"
else
  echo "Skipped ~/.codex/config.toml (already exists)"
fi

echo "Done."
