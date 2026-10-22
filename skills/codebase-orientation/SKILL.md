---
name: codebase-orientation
description: Orient in an unfamiliar multi-file codebase before changing anything - find entry points, the core function, data models, architectural patterns, state, tests and constraints, then report a short mental map. Use when dropped into a repo you haven't read (an AI-enabled coding interview, a take-home, a new project), when the user says "orient", "get me up to speed", "what am I looking at", "map this codebase", or before the first change in code you haven't read.
---

# Codebase orientation

Read before you prompt or edit. Changes made without a map conflict with existing patterns, rebuild helpers that already exist, and break on data shapes nobody checked. Budget 5-10 minutes; it pays back during implementation, because every later instruction can name real classes and functions.

**Do not change any code during orientation.** Read first, then report the map.

## The pass (in order, stop each step when you can answer its question)

1. **Shape of the tree.** List every file (`find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*'`, or `git ls-files`). From names alone: is it MVC, layered (presentation / logic / data access), or grouped by feature? Note the language, framework, build and test commands (package.json, pyproject, Makefile, README).
2. **Entry points.** Where does execution start? `main`, the CLI, the request handlers / routes, the game loop. Trace one real request or command from there to its end and note each handoff.
3. **The hard core.** Find the one function or class everything is built around (usually the longest, most-called, or most-branching). Learn its inputs, outputs and callers before reading the simpler files.
4. **Data models and hierarchy.** What are the core objects and how do they contain or reference each other (Game -> Board -> Cell)? Write down the actual shapes, including ids, enums, and nullable fields. Most later bugs trace back to a wrong assumption here.
5. **Patterns and boundaries.** Is data access behind a repository/service layer? Is validation done in one place? Follow the existing pattern even when a shortcut is easier, and push back on suggestions that would scatter it.
6. **Public interfaces.** For the key classes, what is public versus internal? Use `getCards()`, not the private `cards` array. List the interfaces a change will need so they can be named explicitly.
7. **State.** Where does state live and who mutates it? Is there one source of truth or several copies? Side effects and bugs cluster where state changes.
8. **Tests.** Read them; they document intended behavior. Run them. All green means the baseline works; a red test may be the task itself. If a debugger is available, set one breakpoint on the core path and look at real data.
9. **Constraints.** Scan comments, config and TODOs for limits and assumptions ("works up to 10k inputs", rate limits, hard-coded sizes). They preview what later requirements will stress.

## Using AI while orienting

- Speed up understanding, don't outsource it. Good asks: "What does `GameBoard` do?", "How does data flow from the handler to the database?", "Explain this decorator / generic / framework idiom".
- **Verify every AI claim against the code** before building on it. AI misreads purpose, misses side effects, and describes what code *should* do. If it says "returns the shortest path", check whether it actually returns all paths.

## Output

Reply with a map no longer than one screen:

```
Stack / run / test:  <language, framework, commands; test result>
Entry point:         <file:line> -> <handoffs, in order>
Core:                <function or class, file:line> - <in -> out>
Data model:          <objects and how they relate; key fields>
Patterns to follow:  <layering, where validation and data access live>
State:               <where it lives, who writes it>
Constraints/risks:   <limits, TODOs, failing tests>
Open questions:      <what reading didn't settle; ask a teammate or the interviewer>
Read first:          <files in order, one line each on why>
```

Cite `file:line` for every claim. Mark anything inferred rather than read as "(inferred)".

## In a live interview

- Narrate as you learn: "The Board is a 2D grid of Cells, and each cell tracks its own state and neighbors." Reading out loud is signal; silence reads as dead air.
- It's fine to say "I want to understand the codebase before I change it." Jumping straight to prompting is a known failure signal.
- Be seen in the files, not just in summaries.
- Before bringing this skill (or any SKILL.md / CLAUDE.md) into an interview, ask first. The interviewer has to separate your judgment from your tooling's.

Source: Hello Interview, "Codebase Orientation" (Learn AI Coding -> Fundamentals).
