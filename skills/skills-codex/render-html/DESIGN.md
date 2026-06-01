# /render-html Design Reference

This document is the visual and information-design companion to `SKILL.md`.
Use it when writing source Markdown for `/render-html`, especially for research
reports, experiment summaries, evaluation dashboards, and chart-heavy artifacts.

The goal is simple:

> Write Markdown that turns into HTML with strong hierarchy, readable emphasis,
> and charts/tables that support the argument instead of floating beside it.

## 1. Design intent

`/render-html` has two visual modes:

- `academic`: long-form, reader-first, argument-driven
- `dashboard`: dense, scanning-first, status-driven

Choose based on reading behavior, not just artifact type.

Use `academic` when the reader should understand:

- what the claim is
- why it matters
- what evidence supports it
- what caveats remain

Use `dashboard` when the reader should quickly inspect:

- current status
- scorecards
- ranked items
- multiple comparable metrics
- compact experiment state

## 2. Writing for the renderer

The renderer is strongest when the Markdown already has clean rhetorical
structure. Write in blocks that map cleanly to HTML sections.

Recommended section rhythm:

1. `Executive Verdict` or `Summary`
2. `Problem` or `Context`
3. `Method` or `Workflow`
4. `Evidence` or `Results`
5. `Risks` or `Limitations`
6. `Next Actions`

For chart-heavy reports, keep this sequence:

1. the claim
2. the metric that tests the claim
3. the chart/table
4. the interpretation
5. the caveat

Do not drop a figure or table without a one-line framing sentence before it and
a one-line interpretation after it.

## 3. Visual hierarchy rules

### 3.1 Titles

Use one clear H1. Keep it concrete.

Good:

```md
# BTEG-Memory Research Idea Evaluation
```

Weak:

```md
# Notes
# Results and Thoughts
```

### 3.2 H2 sections

Use H2 for top-level reading anchors. The TOC depends on them.

Good H2 labels:

- `Executive Verdict`
- `Novelty Matrix`
- `Review Findings`
- `Pressure Curve Results`
- `Recommended Next Actions`

### 3.3 H3 sections

Use H3 for comparisons, subclaims, or analysis slices.

Good:

```md
## Pressure Curve Results

### High pressure
### Low pressure
### Why the gap appears
```

### 3.4 Emphasis

Use emphasis sparingly.

- `**bold**` is for the sentence or phrase the reader must retain
- `` `code` `` is for literals, metrics, method names, budgets, filenames
- `> blockquote` is for thesis lines, reframed claims, or pull quotes

Avoid stacking emphasis like bold inside blockquotes inside tables unless the
content is genuinely central.

## 4. Blockquote guidance

Plain blockquotes are the best way to surface a thesis statement or a reframed
research claim.

Use them for:

- the paper's strongest one-sentence thesis
- the reviewer's core objection
- the reframed problem statement

Example:

```md
> Formulate hot-memory management as a budgeted policy problem, then show that
> typed temporal evidence relations improve add / reject / evict / compact /
> route decisions under high memory pressure.
```

Keep blockquotes to 1-3 lines of content when possible. Long multi-paragraph
quotes weaken their visual punch.

## 5. Callout system

The renderer recognizes emoji-prefixed blockquotes and routes them to callout
styles. Use them intentionally.

```md
> 💡 Best framing: treat retrieval wins as supporting evidence, not the main claim.
> ⚠️ Risk: reviewers may call the graph schema decorative without relation ablations.
> ✅ Strong point: model-only cleanup is already part of the baseline story.
> 🚨 Blocking issue: novelty weakens if the paper is framed as generic graph memory.
```

Recommended use:

- `💡` for design guidance, interpretation, or framing insight
- `⚠️` for risk, caveat, or caution
- `✅` for validated strengths or confirmed takeaways
- `🚨` for blocking issues or high-priority failures

Do not use callouts for ordinary paragraphs. They work best when rare.

## 6. Tables: when and how

Tables are the renderer's strongest chart substitute for many research reports.
Prefer them when exact values matter.

Use tables for:

- scorecards
- baseline comparisons
- claims matrices
- experiment plans
- literature overlap maps

### 6.1 Good table pattern

```md
| Method | Budget | Recall | Overhead | Note |
|---|---:|---:|---:|---|
| FIFO | 1024 | 0.71 | 0.05 | Simple recency baseline |
| BTEG | 1024 | 0.89 | 0.03 | Best high-pressure tradeoff |
```

Rules:

- keep column names short
- align numbers right with `---:`
- keep one semantic unit per cell
- avoid paragraphs inside cells

### 6.2 When not to use a table

Avoid tables when:

- there are only 2-3 bullets and no numeric comparison
- the point is sequential process rather than comparison
- the cell text becomes essay-length

In those cases, use short sections or a diagram-style code block.

## 7. Diagram-style blocks

ASCII or pseudo-diagram code fences render well as process illustrations.

Use them for:

- workflow graphs
- pipeline stages
- decision loops
- lifecycle transitions

Example:

```text
Candidate memory
  -> relation detection
  -> value / cost scoring
  -> budgeted action selection
  -> hot memory or cold route
```

Keep these diagrams narrow. If a diagram wraps visually, it stops functioning as
a diagram.

## 8. Chart and figure guidance

`/render-html` does not generate charts by itself. It renders whatever chart
artifact you reference or describe. When you include charts in the source
artifact, design them around interpretation.

### 8.1 Preferred chart types by question

Use:

- line charts for pressure curves and scaling curves
- grouped bars for baseline comparisons across a small number of methods
- stacked bars for composition changes like hot-memory occupancy
- scatter plots for quality-cost Pareto frontiers
- heatmaps only when the matrix is small and label density stays readable

Avoid:

- pie charts for research comparisons
- radar charts unless the dimensions are very few and very stable
- overplotted multi-line charts with more than 5 series

### 8.2 Chart framing in Markdown

Before a chart:

```md
The main question is whether BTEG separates from model-only cleanup only when
memory pressure becomes high.
```

After a chart:

```md
The gap is small below 60% utilization and opens sharply above 85%, which
supports the pressure-dependent claim rather than a universal superiority claim.
```

### 8.3 Chart caption checklist

Every chart or image should make clear:

- what is being compared
- what the x-axis means
- what the y-axis means
- whether bigger is better
- what the intended takeaway is

If an image is embedded with Markdown:

```md
![Pressure curve comparing BTEG, FIFO, and model-only cleanup across hot-memory utilization bands](./figures/pressure_curve.png)
```

Write alt text like a real caption, not a filename.

## 9. Academic vs dashboard design choices

### 9.1 `academic` template

Best for:

- argument-driven reports
- idea evaluations
- review summaries
- method proposals
- claim-evidence documents

Write source Markdown with:

- more prose around figures
- fewer but stronger callouts
- section-level narrative
- longer tables with explanatory final columns

### 9.2 `dashboard` template

Best for:

- run status
- research-wiki cockpit views
- score summaries
- ranked lists
- experiment trackers

Write source Markdown with:

- short sections
- compact tables
- more repeated metric structure
- fewer long paragraphs

## 10. Color and contrast guidance

The templates aim for warm, paper-like readability. To preserve that:

- avoid assuming browser-default blockquote/table colors
- make pull quotes and callouts lighter than code blocks
- reserve saturated color for emphasis, not full-surface fills
- keep body text on light backgrounds unless the entire theme is explicitly dark

When adding new styles:

- check regular paragraph contrast first
- then blockquotes
- then table headers
- then inline code
- then callouts

If one element looks "special" but is less readable, readability wins.

## 11. Common report patterns

### 11.1 Research evaluation report

```md
# Title

## Executive Verdict
> One-sentence thesis

## Workflow Used
## Problem Anchor
## Best Framing
## Novelty Matrix
## Review Findings
## Experiment Plan Assessment
## Scorecard
## Recommended Next Actions
```

### 11.2 Experiment results report

```md
# Title

## Summary
## Setup
## Main Results
## Breakdown by condition
## Ablations
## Failure cases
## Limitations
## Next run
```

### 11.3 Literature comparison report

```md
# Title

## Research Question
## Screening Criteria
## Closest Papers
## Overlap Matrix
## Differentiation Strategy
## Positioning Statement
```

## 12. Anti-patterns

Avoid these when authoring Markdown for `/render-html`:

- opening with a giant table before any framing text
- using 6 callouts in a row
- using tables for prose arguments
- putting filenames or raw IDs in headings
- letting one section mix verdict, method, literature, and TODOs without labels
- using blockquotes for long background explanation
- embedding giant images without captions

## 13. Design checklist before render

Before generating HTML, check:

1. Does the H2 structure match the reading flow?
2. Is the strongest takeaway visible within the first screen?
3. Does every table answer a specific question?
4. Does every chart have framing text before and interpretation after?
5. Are callouts rare enough to matter?
6. Are blockquotes short and readable?
7. Are numeric columns right-aligned?
8. Is the artifact better as `academic` or `dashboard`?

## 14. Quick authoring examples

### Thesis block

```md
## Executive Verdict

> BTEG is strongest as a hot-memory policy paper, not as a generic graph
> retrieval paper.
```

### Risk callout

```md
> ⚠️ Novelty weakens quickly if the contribution is framed as "graph memory for agents"
> rather than "bounded prompt-resident memory optimization."
```

### Claims matrix

```md
| Result pattern | Allowed claim | Forbidden claim |
|---|---|---|
| Wins only under high pressure | Structured policy matters when memory is scarce | BTEG is always better |
| Strong model narrows the gap | Policy improves cost-quality tradeoff | Strong models cannot manage memory |
```

### Workflow diagram

```text
Project docs
  -> problem anchor
  -> novelty scan
  -> reviewer-style critique
  -> scorecard
  -> next actions
```

## 15. Maintenance note

If you change template behavior in ways that affect emphasis, spacing, chart
legibility, or table density, update this file alongside the template so the
skill's design guidance stays honest.
