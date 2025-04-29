# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- Generate code: `gleam run -m squirrel`
- Build/Run: `gleam run` (server), `pnpm build` (client)
- Tests: `gleam test` (all tests), `gleam test ARGUMENTS` (specific tests)
- Type checking: `gleam check`
- Format code: `gleam format` or `gleam format --check` (verify formatting)

## Code Style Guidelines
- Imports: Alphabetical ordering preferred
- Formatting: Use Gleam's built-in formatter (`gleam format`)
- Types: Define types with `pub type` in context-appropriate files
- Error handling: Use Result type with pattern matching; prefer `case` expressions
- Use middleware pattern for web request handling
- Follow functional programming style with immutable data
- Naming: Snake case for functions/variables, PascalCase for types
- Comments: Use `///` for documenting functions
- Patterns: Leverage pattern matching with `use` expressions for control flow
- Do not modify `sql.gleam` files. They are generated from the `sql` directories via `gleam run -m squirrel`
