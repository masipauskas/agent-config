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
