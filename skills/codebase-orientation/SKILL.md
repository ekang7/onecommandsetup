---
name: codebase-orientation
description: Use at the start of work in an unfamiliar codebase, before writing or changing any code. Builds a map of entry points, core logic, data models, patterns, state, tests, and constraints.
---
# Codebase orientation

Do not change any code during orientation. Read first. Produce a map.

## Steps
1. List the file tree (`find . -type f -not -path '*/.git/*' | head -200`). Identify the architecture pattern: layers, modules by feature, MVC, or other.
2. Find the entry points: app startup, API routes (e.g. FastAPI routers), CLI main, workers. Trace one request from entry to storage and back.
3. Find the core: the one or two functions or classes that do the real work. State their inputs, outputs, and side effects.
4. Map the data models: the main classes or tables, their fields, and how they relate. Note where data changes shape.
5. Note the patterns to follow: where database access lives, how errors are handled, how config is loaded, naming and style conventions. New code must follow these patterns.
6. List public interfaces: methods other modules should call. Do not reach into private internals.
7. Find where state lives and how it changes. Identify the single source of truth.
8. Read and run the existing tests. Report which pass and which fail.
9. Note constraints from comments, config, and docs (limits, performance notes, TODOs).

## Output: ORIENTATION.md
- One-paragraph summary of what the system does
- Request flow, step by step, with file and function names
- Data models and relationships
- Patterns to follow, and things not to do
- Test status
- Open questions to ask a teammate
- Suggested files to read first, in order

## Rules
- Quote file paths and function names exactly.
- Say "unverified" for anything inferred and not confirmed in the code.
- Never describe what code should do; describe what it does.
