---
name: research-refine
description: "Freeze a selected research candidate into one problem-anchored thesis and an implementable method sketch. Use after idea selection for 打磨idea, refine approach, or method concretization; use research-blueprint for the full detailed research plan."
argument-hint: [selected-candidate-or-proposal]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, WebSearch, WebFetch, mcp__codex__codex, mcp__codex__codex-reply
---

# Research Refine: Idea Freeze

Turn the selected candidate **$ARGUMENTS** into a stable Idea Freeze.

This skill is the bridge between candidate selection and a full executable
research plan. It answers: **what exact problem are we solving, what is the one
main thesis, and what is the smallest method that could test it?**

It does not replace `/idea-creator`, `/novelty-check`, or
`/research-blueprint`.

## Boundary

```text
candidate pool
  -> selected candidate
  -> Problem Anchor
  -> one dominant method thesis
  -> minimal mechanism validation
  -> FINAL_PROPOSAL.md
  -> research-blueprint
```

Do not use this stage to add unrelated modules, expand the benchmark list, or
write a full 16-week plan. If the problem itself is still uncertain, return to
`idea-discovery`; if the problem is fixed but the method is underdeveloped,
continue here.

## Inputs

Read, when present:

- selected record in `idea-stage/IDEA_CANDIDATES.md`;
- `idea-stage/IDEA_REPORT.md`;
- `idea-stage/TOPIC_CANDIDATES.md` and `REFERENCE_DECONSTRUCTION.md`;
- `docs/project/RESEARCH_BRIEF.md`;
- `idea-stage/IDEA_MEMORY.md`;
- `experiments/NEGATIVE_RESULTS.md`;
- relevant local papers and codebase notes.

Preserve the candidate's evidence gaps, source locators, minimum discriminating
test, and conclusion boundary. A novelty check is evidence about overlap, not
permission to change the original problem.

Read `../../shared-references/autosci-lite-patterns.md`. A-E paths may be used
to choose a route for this selected problem; broad candidate generation remains
owned by `idea-creator`.

## Phase 1: Freeze the Problem Anchor

Write an immutable anchor before designing the method:

- **Bottom-line problem**: exact technical problem;
- **Must-solve bottleneck**: where current methods fail;
- **Target user/query**: what input is available and what output is required;
- **Non-goals**: tempting but excluded tasks;
- **Constraints**: data, compute, time, venue, tooling, deployment;
- **Success condition**: evidence that would count as solving the problem;
- **Evidence-backed question**: source locators and unresolved evidence;
- **Minimum discriminating test**: comparison that separates explanations;
- **Conclusion boundary**: strongest claim allowed and claims forbidden.

Copy this anchor verbatim into every refinement artifact.

## Phase 2: Identify the Technical Gap

Answer in order:

1. Where exactly does the strongest baseline fail?
2. Why do larger models, more data, or naive stacking not address the failure?
3. What is the smallest adequate intervention?
4. What simpler explanation could produce the same result?
5. What evidence is needed before the method can be believed?

If no concrete bottleneck remains, stop and route back to candidate discovery.

## Phase 3: Freeze One Method Thesis

Choose one route:

- **minimal route**: smallest mechanism that targets the bottleneck;
- **frontier route**: current primitive only when it naturally matches the bottleneck;
- **diagnostic route**: an experiment or analysis that resolves a real contradiction.

The result must contain:

- one-sentence method thesis;
- one dominant contribution;
- at most one supporting contribution;
- frozen/reused components;
- new trainable or algorithmic components;
- explicitly excluded additions;
- representation and interface;
- training or estimation objective;
- inference path;
- failure modes and diagnostics.

If two routes are plausible, compare them explicitly and select one. Do not merge
both into a larger system by default.

## Phase 4: Minimal Mechanism Validation

Define at most three core checks. For each:

- hypothesis;
- dataset and split;
- proposed method and strongest baseline;
- necessary ablation or simpler explanation;
- decisive metric;
- expected directional result;
- failure interpretation;
- kill, narrow, or pivot condition.

These checks are not the full experiment plan. They are the minimum evidence
needed to decide whether the frozen thesis deserves a detailed blueprint.

## Phase 5: Review and Revision

Use an external reviewer or prompt-only review when requested. The review must
check:

- problem fidelity;
- method specificity;
- contribution parsimony;
- novelty boundary;
- feasibility;
- falsifiability;
- scope drift.

Do not optimize for a numerical score by adding more components. A revision is
accepted only when it improves the anchor, mechanism, or discriminating test.

## Output

Write:

- `refine-logs/FINAL_PROPOSAL.md`;
- `refine-logs/REFINEMENT_REPORT.md`;
- `refine-logs/REVIEW_SUMMARY.md` when review was used;
- `refine-logs/REFINE_STATE.json` for resumable runs.

`FINAL_PROPOSAL.md` must use this structure:

```markdown
# Idea Freeze: [title]

## 1. Problem Anchor
- Bottom-line problem:
- Must-solve bottleneck:
- Target input / output:
- Non-goals:
- Constraints:
- Success condition:
- Evidence-backed question and locators:
- Remaining evidence conditions:
- Minimum discriminating test:
- Conclusion boundary:

## 2. Technical Gap
- Strongest baseline failure:
- Why naive fixes fail:
- Missing mechanism:
- Simpler competing explanation:

## 3. Method Thesis
- One-sentence thesis:
- Dominant contribution:
- Optional supporting contribution:
- Explicit non-contributions:

## 4. Proposed Method
### Complexity Budget
### System Overview
### Core Mechanism
### Training / Estimation
### Inference
### Failure Modes and Diagnostics

## 5. Minimal Mechanism Validation
### Check 1
### Check 2
### Check 3

## 6. Novelty and Feasibility Boundary
- Closest work:
- Exact differentiation:
- Data / compute / timeline:
- Main reviewer objection:
- Kill or pivot condition:

## 7. Handoff to Executable Research Plan
- Claims to formalize:
- Theory obligations:
- Dataset and query protocol:
- Baseline families:
- Decision gates:
- Required implementation modules:
```

## Handoff

Once the user accepts the Idea Freeze, invoke `/research-blueprint`. The
blueprint must expand this document into the PDF-level structure:

```text
positioning and corrections
  -> formal model layers
  -> theory and proof obligations
  -> exact / approximate inference boundaries
  -> capability matrix
  -> tasks, datasets, baselines, metrics
  -> claim-driven gates and pivots
  -> week-by-week execution plan
  -> code, compute, risk, paper package
```
