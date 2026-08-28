---
name: "integrity-forensics"
description: "Audit research automation for hidden finding loss, self-acquittal, scope drift, and unsafe reviewer loops. Use before accepting automated idea, novelty, experiment, claim, or paper-review workflows."
---

# Research Integrity Forensics

Audit the research automation and evidence trail at: **$ARGUMENTS**

## Purpose

This skill checks whether an automated workflow preserved the evidence needed
for a trustworthy review or gate decision. It is not a paper-quality reviewer.

## Required Inputs

Read the target artifact and, when available:

- run state and phase history;
- complete reviewer prompts and responses;
- findings or obligations ledger;
- changes between rounds;
- experiment and validation manifests;
- final gate or acceptance record.

If a required record is missing, report `missing-evidence`; do not infer that
the underlying step was clean.

## Audit Questions

### Evidence preservation

Check that every round preserves exact input references, the complete raw review
response, extracted findings, changes, and the next verification result.

### Finding continuity

Classify each finding as `open`, `resolved`, `superseded`, `not-reproducible`,
`unresolved`, or `disappeared-without-rationale`. The last state is an
integrity failure.

### Scope and contract drift

Compare rounds for silent changes to the problem, data split, supervision,
metric, model family, claim boundary, or acceptance threshold. Any change
without a new version and rationale is `scope-drift`.

### Reviewer independence

Check that the executor did not supply the only acceptance judgment. A score
without the full response, source identity, or trace is
`insufficient-review-evidence`.

### Loop termination

Distinguish `execution-complete`, `review-positive`, `accepted`, and
`unresolved`. These states must not be collapsed.

## Required Output

Write:

```markdown
# Research Integrity Forensics Report

## Verdict
- Status: CLEAN | CLEAN_WITH_OPEN_OBLIGATIONS | BLOCKED_BY_MISSING_EVIDENCE | INTEGRITY_VIOLATION
- Scope:
- Audited at:

## Evidence Inventory
| Artifact | Present | Hash or identity | Complete |
|---|---:|---|---:|

## Obligation Ledger
| ID | Original finding | Current state | Evidence | Rationale |
|---|---|---|---|---|

## Drift Check
- Problem:
- Data:
- Supervision:
- Metric:
- Claim boundary:
- Acceptance rule:

## Loop Check
- Maximum rounds registered:
- Rounds observed:
- Raw reviewer responses preserved:
- Positive stop independent:
- Executor self-acquittal detected:

## Missing Evidence

## Allowed Next Action
```

## Decision Rules

- `INTEGRITY_VIOLATION` if findings disappeared, evidence was selectively
  hidden, or the executor self-acquitted a quality verdict.
- `BLOCKED_BY_MISSING_EVIDENCE` if a required raw response, trace, manifest, or
  change record is absent.
- `CLEAN_WITH_OPEN_OBLIGATIONS` if the trail is intact but material findings
  remain unresolved.
- `CLEAN` only when the trail is complete and all obligations are resolved or
  explicitly superseded.

This audit reports integrity, not novelty, correctness, or publishability.
