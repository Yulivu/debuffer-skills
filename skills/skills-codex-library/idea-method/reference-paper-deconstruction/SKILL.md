---
name: "reference-paper-deconstruction"
description: "Turn one core reference paper and up to three comparable papers into evidence-grounded topic candidates. Use when the user asks to 拆解对标论文, 从论文找选题, analyze reference papers for research ideas, map conflicting findings, or wants a reference-led idea start before novelty checking."
argument-hint: "[research topic or core paper] — ref papers: <core>; <comparator-1>; <comparator-2>; <comparator-3>"
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, WebSearch, WebFetch
---

# Reference Paper Deconstruction

Convert a small set of comparable papers into an evidence-grounded topic
selection artifact. This skill owns **reference-paper analysis and candidate
evidence**. It does not replace `/idea-creator`'s broad A-E generation,
`/novelty-check`'s novelty verdict, or `/research-refine`'s method design.

## When to Use

Use before broad idea generation when the user has a reference paper, a small
paper set, or a request to find a topic from prior work. It is especially
useful for starts where the user wants to understand what can be learned from
strong papers without copying their prose, claims, figures, or experiments.

```text
/reference-paper-deconstruction "<research direction>" \
  — ref papers: <core source>; <optional comparator>; <optional comparator>; <optional comparator>
```

`<source>` may be a local PDF, an arXiv identifier or URL, another paper URL,
or an already-ingested local paper. One core paper is required. If fewer than
four papers are supplied, identify up to three comparators that match the core
paper's question, design, data type, and intended venue level; do not select
papers only because they are highly cited.

## Non-Goals and Boundaries

- Do not copy sentences, tables, figure layouts, methods text, data, citations,
  or claims from a reference paper.
- Do not treat a stated future-work item as a verified open problem.
- Do not issue a novelty verdict. Only `/novelty-check` can decide whether a
  candidate remains differentiated after recent-literature search.
- Do not promote a method limitation into a topic unless fixing it could change
  the conclusion's credibility, mechanism interpretation, or applicability.
- Do not treat a unique dataset or setting as a contribution unless it exposes
  a transferable boundary, assumption, or failure mode.

## Inputs and Evidence Discipline

For every finding that becomes a topic lead, record its source paper and the
smallest available locator: section, paragraph role, figure/table, page, or
appendix item. Prefer original studies over reviews for pivotal claims.

When evidence is unavailable or only inferred from an abstract, label it
`needs_source_check`; never silently convert it into a confirmed gap.

## Workflow

### 1. Build a Comparable Reference Set

Create a reference-selection card for the core paper and each comparator:

- research question and claimed contribution;
- design, data type, and evaluation setting;
- methods or analysis relevant to the user's direction;
- what is structurally reusable;
- what is inapplicable or must not be copied.

The core paper should be the closest match. Comparators separate a field
convention from a single paper's idiosyncratic choice.

### 2. Perform the Four-Layer Deconstruction

#### Problem Layer

Identify the paper's question, prior consensus, explicit and implicit gap,
assumptions, and stated conclusion boundary.

#### Structure Layer

Describe what each major section and material paragraph does for the argument:
context, gap, method rationale, main result, robustness, mechanism, limitation,
or implication. Record functions, not copied prose.

#### Evidence Layer

Create a figure/table evidence map. Every main visual must state:

- the question it answers;
- the claim it supports;
- the evidence type: phenomenon, robustness, comparison, diagnostic, or
  mechanism clue;
- the strongest conclusion it permits;
- the conclusion it does not permit.

#### Expression Layer

Record only reusable rhetorical functions, such as establishing consensus,
stating insufficient evidence, describing conflict, limiting causality, and
acknowledging scope. Do not store sentence banks or long quotations.

### 3. Extract Four Kinds of Gap Leads

Group evidence-grounded leads under these labels:

1. `future_direction` — an author-stated next step. Mark it
   `needs_recency_check` until recent work confirms it remains open.
2. `conflicting_finding` — two or more studies disagree. Build a contradiction
   matrix across data, variable definitions, metrics, protocols, assumptions,
   and settings; the lead must propose a discriminating explanation.
3. `method_limit` — a design, measurement, control, or analysis weakness. State
   how correcting it could change the conclusion rather than merely improve
   reporting.
4. `unique_setting` — a distinctive dataset, deployment setting, population, or
   resource. State which existing assumption it tests and why the resulting
   finding could transfer beyond that setting.

### 4. Turn Leads into Topic Candidates

For each viable lead, write a candidate with:

- a precise unanswered question;
- the evidence-backed gap and source locators;
- why the answer matters;
- competing explanations or a falsifiable hypothesis;
- the minimum discriminating evidence, including data, baseline, comparison,
  metric, and expected result;
- the strongest permissible conclusion and its explicit boundary;
- a kill condition or reason to narrow the candidate.

Run two gates. First, answer the four topic questions:

1. Is the question genuinely under-answered?
2. Why does the answer matter?
3. What can current data, time, methods, and compute actually establish?
4. What specific understanding would change if the work succeeds?

Second, apply the advisor gate:

- gap is supported by evidence;
- critical data or setting is obtainable;
- the proposed design can distinguish the stated explanations;
- the conclusion boundary is explicit.

Set each candidate status to exactly one of:

- `ready_for_novelty_check` — all gate items are currently supported;
- `needs_evidence` — promising but at least one needed source, resource, or
  design element remains unresolved;
- `blocked` — the gap is unsupported, the decisive evidence is unavailable, or
  the design cannot answer the question.

These statuses are planning signals, not research-quality or novelty verdicts.

### 5. Write Versioned Outputs

Follow `../../skills-codex/shared-references/output-versioning.md`: write timestamped copies
and update the fixed-name latest copy.

Write these artifacts under `idea-stage/`:

#### `REFERENCE_DECONSTRUCTION.md`

```markdown
# Reference Paper Deconstruction

## Scope and Reference Set
## Reference Selection Cards
## Four-Layer Deconstruction
### Problem Layer
### Structure Layer
### Evidence Map
### Expression Functions
## Gap Leads
### Future Directions
### Conflicting Findings
### Method Limits
### Unique Settings
## Topic Gate Assessment
## Candidate Rationale and Boundaries
## Handoff
```

#### `TOPIC_CANDIDATES.md`

Keep this compact and machine-readable-by-structure. Include at most five
candidates and, for each one, the candidate ID, one-sentence question, gap
source type, source locators, hypothesis or competing explanations, minimum
discriminating evidence, conclusion boundary, status, and next required action.

## Handoff Rules

- `/idea-discovery — reference-led` consumes both artifacts before broad
  landscape search.
- `/idea-creator` may use candidates as evidence-backed seeds, but retains
  ownership of broader A-E candidate generation and ranking.
- `/novelty-check` is mandatory before a `ready_for_novelty_check` candidate is
  treated as differentiated.
- `/research-refine` may refine only a selected candidate while preserving its
  recorded evidence gaps, minimum validation, and conclusion boundary.
