---
name: experiment-writeup-audit
description: "Audit whether a paper's experiment section is complete and convincing: settings, baselines, metrics, coverage of common experiment families, and quality of result analysis. Use when the user wants to know whether the paper still needs more experiments or whether the current experiments are written up poorly."
argument-hint: [paper-dir-or-narrative-doc]
allowed-tools: Bash(*), Read, Grep, Glob, Write, Edit
---

# Experiment Writeup Audit

Audit the experiment writeup as a paper artifact, not as a raw run artifact.

## Load First

Read `../../shared-references/paper-writing-rules.md`,
`../../shared-references/project-guide-protocol.md`, and
`../../shared-references/venue-profiles.md`.

Focus on the `Experiments` section in the shared reference.

## Inputs

- `paper/sections/*experiments*.tex` if available
- `docs/paper/PAPER_PLAN.md`
- `docs/evidence/EVIDENCE_LEDGER.md`
- `docs/experiments/EXPERIMENT_PROTOCOL.md`
- `docs/experiments/EXPERIMENT_LOG.md`
- result summaries, tables, and figures

## What to Judge

1. Are datasets, splits, metrics, implementation details, hardware, seeds, and
   baselines documented clearly enough?
2. Are the chosen baselines recent and strong enough for the target venue?
3. Which common experiment families are covered:
   overall performance, ablation, parameter, efficiency, compatibility,
   transferability, case study, feature analysis?
4. Are there claims in the paper that lack matching experiments?
5. Does the analysis explain causes and limitations, or only restate numbers?
6. Are numbers reused consistently between the main result table and later
   analysis paragraphs?

## Output

Write `docs/paper/EXPERIMENT_WRITEUP_AUDIT.md` with:

- `must_add_experiments`
- `should_strengthen_writeup`
- `optional_experiments`
- `claim_alignment_risks`

Keep it compact. If the main issue is writing rather than missing runs, say so
explicitly.

## Rules

- Do not demand extra experiments unless they are genuinely claim-critical or
  venue-critical.
- Separate `missing evidence` from `poor explanation`.
- If only smoke/pilot evidence exists, redirect to experiment planning rather
  than pretending the writeup is ready.

## See Also

- `/experiment-plan`
- `/experiment-audit`
- `/paper-plan`
- `/paper-write`
