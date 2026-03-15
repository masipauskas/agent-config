#!/usr/bin/env zsh
set -euo pipefail

REPO_DIR=${0:A:h}

remove_if_mine() {
  local target=$1
  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$REPO_DIR"* ]]; then
    rm "$target"
    echo "Removed $target"
  fi
}

remove_if_mine ~/.claude/CLAUDE.md
remove_if_mine ~/.claude/ai-instructions.md
remove_if_mine ~/.claude/settings.json

for f in "$REPO_DIR"/agents/*.md; do
  remove_if_mine ~/.claude/agents/${f:t}
done

for f in "$REPO_DIR"/global/rules/*.md(N); do
  remove_if_mine ~/.claude/rules/${f:t}
done

remove_if_mine ~/.codex/AGENTS.md
remove_if_mine ~/.codex/ai-instructions.md

echo "Done."
