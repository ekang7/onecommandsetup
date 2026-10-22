---
name: explain-diff
description: Use after the AI writes code, so the user understands every line before moving on. Walks through the change and quizzes the user.
---
# Explain the change

1. Walk through the diff in execution order, not file order.
2. For each function: what it does, why it is written this way, and one alternative that was not chosen and why.
3. Point out any line that is non-obvious, risky, or depends on an assumption.
4. Ask the user three short questions about the code (e.g. "What happens if the input is empty?"). Wait for answers. Correct any mistakes.
5. Keep explanations short. Use the codebase's own names.
