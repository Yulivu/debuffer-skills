---
name: idea-creator
description: "Generate a bounded set of concrete research candidates from a direction, reference paper, codebase, or known limitation. Use for 找idea, brainstorm ideas, candidate generation, or topic exploration."
argument-hint: [research-direction]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, WebSearch, WebFetch, mcp__codex__codex, mcp__codex__codex-reply, mcp__manual_review__review, mcp__manual_review__review_reply
---

# Research Idea Creator

Generate concrete research candidates for: **$ARGUMENTS**

This skill owns **candidate generation**, not complete research-plan writing.
It may propose a minimum validation experiment, but it must not silently expand
each candidate into a full architecture, theorem package, 16-week schedule, or
paper package.

## Inputs

Read the context supplied by `/idea-discovery` when available:

- landscape notes and recent literature;
- `idea-stage/TOPIC_CANDIDATES.md` and `REFERENCE_DECONSTRUCTION.md`;
- `docs/project/RESEARCH_BRIEF.md`;
- `research-wiki/query_pack.md`;
- `idea-stage/IDEA_MEMORY.md`;
- `experiments/NEGATIVE_RESULTS.md`.

Treat wiki gaps and reference-paper future work as search seeds, not as
confirmed novelty. Preserve source locators and conclusion boundaries.

## A-E Candidate Paths

Read `../../shared-references/autosci-lite-patterns.md`. Use the paths as a
coverage menu, not a quota:

| Path | Candidate shape |
|---|---|
| A | Landscape-driven gap plus a concrete method nucleus |
| B | Smallest repair for a concrete limitation of method M |
| C | Combination of M1 and M2 with a testable reason for complementarity |
| D | Break a shared assumption and replace the broken step with a mechanism |
| E | Transfer a mechanism from domain X to Y with an adaptation boundary |

For a sparse direction, include at least one A candidate and one applicable
B-E candidate. For a reference-heavy direction, prefer B-D. Do not invent an E
candidate without naming both domains and the transferable mechanism.

## Generation Protocol

Generate 8-12 candidates. For every candidate, write:

```markdown
### Candidate I-01: [short title]
- Path: A|B|C|D|E
- Question: one precise unanswered question
- Hypothesis: what should happen and why
- Why it matters: why either outcome would teach us something
- Mechanism sketch: the smallest proposed intervention or diagnostic
- Closest work: papers or methods and the exact difference
- Minimum discriminating test: data, comparison, metric, and expected direction
- Paper type: method-primary | audit-support | audit-only
- Method delta: the smallest implementable change to a named step
- Attribution experiment: how the experiment isolates delta
- Resources: data availability, compute, implementation effort, timeline
- Failure risk: the most likely way this can fail
- Kill condition: what result stops or narrows the idea
- Evidence status: supported | needs_evidence | blocked
- Conclusion boundary: strongest claim currently allowed
```

The candidate must be falsifiable. “Apply X to Y and improve the score” is not
enough unless the application exposes a mechanism, assumption, or transferable
boundary.

Run `/method-paper-gate` before finalizing the ledger. A candidate without a
method delta is `audit-only` and must be rewritten or moved to supporting
evidence; it cannot be selected as a method paper.

## Objective Consolidation

After generation:

1. Merge mechanically near-identical hypotheses.
2. Remove only candidates whose required data is unavailable or whose resource
   demand is objectively outside the stated budget.
3. Annotate, rather than eliminate, uncertainty about novelty, impact, or
   implementation difficulty.
4. Keep the full candidate ledger available to later review; do not pre-filter
   based on taste.

For each surviving candidate, add:

- `prior_work`: short evidence note;
- `so_what`: why the result matters;
- `effort_note`: the main implementation burden;
- `minimum_validation`: the cheapest decisive test.

## Review Handoff

Pass the annotated candidate set to `/novelty-check` and `/research-review` when
the entry workflow requests it. Reviewer output can rank or challenge ideas,
but cannot silently change the problem definition. Record reviewer provenance
and, when applicable, `review-tracing.md`.

## Outputs

Write or update:

- `idea-stage/IDEA_CANDIDATES.md`: compact top 3-5 candidates;
- `idea-stage/IDEA_REPORT.md`: full candidate ledger and annotations;
- `idea-stage/IDEA_MEMORY.md`: append-only outcomes and banlist entries.

When `research-wiki/` is active, use its helper and **Write Ideas to Research
Wiki** only for durable idea records, not for unverified novelty claims.

The output must end with a user checkpoint:

```text
Candidate generation is complete.
Select one candidate for Idea Freeze, request a narrower regeneration, or stop.
No response is not approval.
```

## Handoff Boundary

After the user selects a candidate:

```text
selected candidate
  -> /research-refine: Idea Freeze and focused method thesis
  -> /research-blueprint: detailed executable research plan
  -> /experiment-plan: operational experiment protocol
```

Do not call `/research-blueprint` directly on an unselected candidate unless the
user explicitly asks for a speculative plan and the document labels all claims
as hypotheses.
