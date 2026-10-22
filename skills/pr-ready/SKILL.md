---
name: pr-ready
description: Use before declaring any change done. Reviews the diff as a production pull request and writes the PR description.
---
# Production PR check

## Review the diff
1. Show the full diff. Keep it small and focused on the task. Remove unrelated changes.
2. Check each file:
   - Follows existing patterns and naming
   - No dead code, debug prints, or commented-out code
   - Errors are handled; failures are visible, not silent
   - Inputs are validated at boundaries
   - Types are explicit; no unchecked `Any`
   - No secrets or patient data in code, logs, or tests
3. Run the tests, type checker, and linter that the project has. All must pass.

## Write PR.md
Do not commit PR.md unless the user asks.
- What changed and why (two to four sentences)
- How it works (key functions, in order)
- Design decisions and trade-offs considered
- How it was tested (list of tests)
- Known limitations and follow-ups

## Rule
Flag anything the user may not understand. The user must be able to explain every line.
