---
name: ml-experiment
description: Use for any modeling or evaluation experiment. Runs a disciplined experiment and writes up results the user can defend.
---
# ML experiment protocol

1. State the question and the hypothesis in one sentence each.
2. Define the metric and why it fits (e.g. PR-AUC for rare positives; recall at a fixed precision for an operating point). Name what each error type costs.
3. Inspect the data: size, label balance, missing values, leakage risks (anything known only after the prediction time).
4. Split the data. Prefer a time-based split when data has time. If rows share an entity (patient, user, device), split by entity so no entity is in both train and test. Fix random seeds.
5. Run a simple baseline first (majority class, rules, or logistic regression).
6. Change one thing at a time. Record every run: setting, metric, notes.
7. Do error analysis: sample 20 to 50 errors, sort them into categories, count each category.
8. Write RESULTS.md:
   - Question, metric, and why
   - Results table: baseline vs. each variant
   - What the errors look like (categories with counts)
   - What I conclude, and how confident I am (sample size, variance)
   - What I would try next, in priority order

## Rule
Do not claim an improvement smaller than the noise. Estimate the noise with several seeds or a bootstrap confidence interval. State the test set size.
