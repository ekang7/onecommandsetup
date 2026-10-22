---
name: tdd-verification
description: Use when implementing any feature or fix. Write and agree on tests first, implement to make them pass, and verify after every milestone.
---
# Test-driven development and verification

## Before implementing
1. Restate the requirement as inputs and expected outputs.
2. Propose test cases and show them to the user for agreement before writing code. Cover:
   - Happy path
   - Empty or zero input
   - Single element
   - Boundary values
   - Duplicates
   - Invalid or malformed input
   - Scale, if performance matters
3. Write the tests against the intended interface. Run them. Confirm they fail for the right reason.

## Implementing
4. Implement the smallest change that makes the tests pass. Follow existing codebase patterns.
5. Run the full test suite and the type checker or linter (e.g. `pytest`, `mypy`, `ruff`) after each milestone, not only at the end.

## When a test fails
6. State a hypothesis for the failure before changing code. Change one thing at a time.
7. Never delete, skip, or weaken a test to make it pass. Never silence type errors with `Any`, casts, or ignores. Report these as problems instead.

## After implementing
8. Add tests for edge cases found during implementation.
9. Report: tests added, tests passing, anything untested and why.
