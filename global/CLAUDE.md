@ai-instructions.md

## Workflow Defaults

After any rename or refactor, search ALL files (including notebooks/*.py and tests) for old references before declaring done.
After completing a task, run the full test suite and self-review with a subagent before reporting completion.
For multi-step plans, commit after each verified step rather than batching.

## Workflow

Read existing code before editing. Keep changes minimal and on-task.
Match the repository's style, even when it differs from my preferences.
Inspect the codebase instead of inventing patterns.
Run project test/lint commands after changing code.
Use rg for code search. Non-interactive commands only.
Tools (just, uv, gh, etc.) are in PATH. Do not export PATH or search for binaries — if a command is not found, ask the user.

## Response Style

Prefer concise, to-the-point answers. Less prose, more signal.
