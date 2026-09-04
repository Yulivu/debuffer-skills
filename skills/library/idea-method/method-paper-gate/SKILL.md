---
name: method-paper-gate
description: "Force idea candidates toward an implementable method paper instead of an audit, evaluation, benchmark, reproduction, or diagnostic paper. Use when idea discovery produces failure analyses, comparison studies, oracle ceilings, reproduction checks, taxonomy gaps, or 'understand why X fails' candidates without a concrete method delta."
argument-hint: [candidate-or-candidate-ledger]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Skill
---

# Method Paper Gate

Screen candidates for: **$ARGUMENTS**

This gate keeps the paper primary contribution on a **method**, not on an
audit/evaluation/diagnostic finding. Audit work may appear as supporting
evidence, but it must not become the thesis, title, or dominant contribution.

## Paper Type Classification

Classify every candidate as one of:

- **method-primary**: introduces an implementable delta `δ` to a named existing
  method or pipeline.
- **audit-support**: measures, compares, reproduces, or diagnoses an existing
  method. It supports a method-primary claim but is not eligible alone.
- **audit-only**: has no implementable delta and no method thesis. Block from
  `research-refine` and `research-blueprint`.

Use this test:

| Required element | Method paper | Audit paper |
|---|---|---|
| Problem P and closest method M | yes | yes |
| One-sentence thesis `M' = M + δ` | yes | no |
| δ changes a named pipeline step | yes | optional |
| δ input / output / rule is implementable | yes | optional |
| Experiment isolates δ from other changes | yes | optional |
| Paper title/contribution is method | yes | no |

## Audit-Drift Patterns

Convert these audit patterns instead of accepting them as a paper:

- **"Existing methods fail"** -> motivation only; identify the failing step and propose δ.
- **"We measure / quantify / find"** -> rewrite as "We propose / replace / introduce".
- **"What is the ceiling?"** -> oracle or upper-bound analysis; keep it out of the main table and never make it the thesis.
- **"Benchmark comparison"** -> supporting second-setting evidence, not the contribution.
- **"Reproduction check"** -> prerequisite, not the paper.
- **"Taxonomy has no slot"** -> related work and positioning, not the contribution.
- **"Apply X to Y"** -> allowed only when the adaptation is a named mechanism with a transfer/failure boundary.
- **"Diagnostic study"** -> allowed only as minimal mechanism validation; it cannot be the dominant route in `research-refine`.

## Gate Procedure

1. Read the selected candidate or candidate ledger.
2. For every candidate, write:
   - `paper_type`: method-primary | audit-support | audit-only
   - `method_delta`: exact change to a named step
   - `method_interface`: input, output, parameters, and implementation entrypoint
   - `attribution_test`: experiment that isolates δ
   - `audit_role`: supporting experiments allowed for this method
3. Rewrite audit-only candidates by finding the smallest pipeline step that can
   be changed. If no concrete δ exists, mark them `audit-support` and do not
   select them as a method paper.
4. Write `idea-stage/METHOD_PAPER_GATE.md` with statuses and conversion notes.

## Method Output Contract

A method-ready candidate must eventually support this output contract:

```text
one-sentence method thesis
  -> pipeline full diagram, including discarded branches
  -> per-step input / output / parameters
  -> design-decision ledger with evidence status
  -> current limitations and unsupported choices
  -> Z -> W estimator when an oracle or hidden choice is used
  -> main experiment, ablation isolating δ, and second-setting check
```

Do not let the pipeline stop at measurement, comparison, or gap
classification.

## Decision Rules

- `method-primary`: proceed to `/research-refine`.
- `audit-support`: keep as supporting evidence only when a method-primary
  candidate exists; otherwise regenerate.
- `audit-only`: block. Do not advance it and do not name it with
  `Analysis / Evaluation / Benchmark / Study / Toward Understanding`.
- If the user explicitly insists on an audit paper, stop the skill and record
  the decision as `audit-only` in `idea-stage/IDEA_MEMORY.md`; do not silently
  relabel the paper type.

## Handoff

After the gate passes, the next step is `/research-refine`. The refine skill
must read `idea-stage/METHOD_PAPER_GATE.md` and freeze only the
`method-primary` thesis.
