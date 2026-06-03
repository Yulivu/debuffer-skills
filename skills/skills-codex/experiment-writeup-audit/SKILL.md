---
name: experiment-writeup-audit
description: "Audit whether a paper's experiment section is complete and convincing: settings, baselines, metrics, coverage of common experiment families, and quality of result analysis. Use when the user wants to know whether the paper still needs more experiments or whether the current experiments are written up poorly."
argument-hint: [paper-dir-or-narrative-doc]
allowed-tools: Bash(*), Read, Grep, Glob, Write, Edit
---

# Experiment Writeup Audit

Audit the experiment writeup as a paper artifact, not as a raw run artifact.

## Load First

Read `../shared-references/paper-writing-rules.md`,
`../shared-references/project-guide-protocol.md`, and
`../shared-references/venue-profiles.md`.

## Checks

- completeness of experimental settings
- baseline and metric adequacy
- coverage of common experiment families
- claim-to-experiment alignment
- explanatory quality of the analysis
- number consistency between tables, figures, and prose

## Output

Write `docs/paper/EXPERIMENT_WRITEUP_AUDIT.md` with:

- must_add_experiments
- should_strengthen_writeup
- optional_experiments
- claim_alignment_risks

Keep it short and actionable.

## See Also

- `/experiment-plan`
- `/experiment-audit`
- `/paper-plan`
- `/paper-write`
