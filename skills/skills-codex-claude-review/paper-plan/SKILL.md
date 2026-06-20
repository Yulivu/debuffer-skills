---
name: "paper-plan"
description: "Prompt-only by default in the lightweight pack; Claude/Gemini reviewer transport is explicit opt-in. Generate a structured paper outline from audited formal experiment results and review conclusions. Use when user says \"写大纲\", \"paper outline\", \"plan the paper\", \"论文规划\", or wants a paper plan after formal runs and evidence audit. If only smoke, pilot, toy, or validation results exist, produce a gap report or next actions instead of routing to manuscript drafting."
---

> Override for Codex users who want **Claude Code**, not a second Codex agent, to act as the reviewer. Install this package **after** `skills/skills-codex/*`.

## Customized Pack Defaults

This reviewer overlay is opt-in transport only. In the customized lightweight
pack, default to prompt-only review unless the user explicitly asks to use this
overlay reviewer backend:

- Write the review prompt under `review-prompts/` and ask the user to run it in
  a separate conversation with the relevant skills enabled.
- Do not call Claude/Gemini reviewer MCP bridges, APIs, or follow-up status
  tools by default.
- Use pasted review text as the external verdict, then write compact summaries
  such as `REVIEW_SUMMARY.md`, `NEXT_ACTIONS.md`, or the skill-specific log.
- Keep heavy experiments AutoDL/HPC-gated and user-approved; local work stays at
  edits, tests, lint, dry-runs, and tiny smoke checks.
- Keep the manuscript-entry gate from the base `paper-plan`: formal runs plus
  `docs/evidence/EVIDENCE_LEDGER.md` or `CLAIMS_FROM_RESULTS.md` are required
  before a normal `docs/paper/PAPER_PLAN.md` may hand off to drafting.

# Paper Plan: From Review Conclusions to Paper Outline

Generate a structured, section-by-section paper outline from: **$ARGUMENTS**

## Constants

- **REVIEWER_MODEL = `claude-review`** — Claude reviewer invoked through the local `claude-review` MCP bridge. Set `CLAUDE_REVIEW_MODEL` if you need a specific Claude model override.
- **TARGET_VENUE = `ICLR`** — Default venue. User can override (e.g., `/paper-plan "topic" — venue: NeurIPS`). Supported: `ICLR`, `NeurIPS`, `ICML`.
- **MAX_PAGES** — Main body page limit, measured from first page to end of Conclusion section (excluding references, appendix, and acknowledgements). ICLR=9, NeurIPS=9, ICML=8.

## Inputs

The skill expects one or more of these in the project directory:

1. **NARRATIVE_REPORT.md** or **STORY.md** — research narrative with claims and evidence
2. **review-stage/AUTO_REVIEW.md** — auto-review loop conclusions *(fall back to `./AUTO_REVIEW.md` if not found)*
3. **Experiment results** — JSON files in `figures/`, screen logs, tables
4. **idea-stage/IDEA_REPORT.md** — from idea-discovery pipeline (if applicable) *(fall back to `./IDEA_REPORT.md` if not found)*

If none exist, ask the user to describe the paper's contribution in 3-5 sentences.

For regular paper planning, results must be formal and auditable. Smoke, pilot,
toy, or validation runs are blockers for manuscript handoff.

## Workflow

### Step 1: Extract Claims and Evidence

Run the paper-plan entry gate before drafting the outline:

1. Confirm formal run evidence exists for paper-level claims.
2. Confirm `docs/evidence/EVIDENCE_LEDGER.md`, `CLAIMS_FROM_RESULTS.md`, or an
   equivalent audit maps claims to raw evidence and unresolved gaps.
3. If either check fails, do not produce a normal paper plan and do not list
   `/paper-write` or `/paper-writing` as a next step. Produce
   `docs/project/NEXT_ACTIONS.md` or `docs/paper/GAP_REPORT.md` and stop.

Read all available narrative documents and extract:

1. **Core claims** (3-5 main contributions)
2. **Evidence** for each claim (which experiments, which metrics, which figures)
3. **Known weaknesses** (from reviewer feedback)
4. **Suggested framing** (from review conclusions)

Build a **Claims-Evidence Matrix**:

```markdown
| Claim | Evidence | Status | Section |
|-------|----------|--------|---------|
| [claim 1] | [exp A, metric B] | Supported | §3.2 |
| [claim 2] | [exp C] | Partially supported | §4.1 |
```

### Step 2: Determine Paper Type and Structure

Based on TARGET_VENUE and paper content, classify and select structure.

**IMPORTANT**: The section count is FLEXIBLE (5-8 sections). Choose what fits the content best. The templates below are starting points, not rigid constraints.

For systems, memory, query-processing, benchmark, IEEE, or Overleaf papers,
read `../../skills-codex/shared-references/icde-yu-memory-paper-structure.md`
and prefer its `ICDE_YU_Memory` section topology when it fits the evidence.

**Empirical/Diagnostic paper:**
```
1. Introduction (1.5 pages)
2. Related Work (1 page)
3. Method / Setup (1.5 pages)
4. Experiments (3 pages)
5. Analysis / Discussion (1 page)
6. Conclusion (0.5 pages)
```

**Theory + Experiments paper:**
```
1. Introduction (1.5 pages)
2. Related Work (1 page)
3. Preliminaries & Modeling (1.5 pages)
4. Experiments (1.5 pages)
5. Theory Part A (1.5 pages)
6. Theory Part B (1.5 pages)
7. Conclusion (0.5 pages)
— Total: 9 pages
```
Theory papers often need 7 sections (splitting theory into estimation + optimization, or setup + analysis). The total page budget MUST sum to MAX_PAGES.

Theory papers should:
- Include **proof sketch** locations (not just theorem statements)
- Plan a **comparison table** of prior theoretical bounds vs. this paper's bounds
- Identify which proofs go in appendix vs. main body

**Method paper:**
```
1. Introduction (1.5 pages)
2. Related Work (1 page)
3. Method (2 pages)
4. Experiments (2.5 pages)
5. Ablation / Analysis (1 page)
6. Conclusion (0.5 pages)
```

### Step 3: Section-by-Section Planning

For each section, specify:

```markdown
### §0 Abstract
- **One-sentence problem**: [what gap this paper addresses]
- **Approach**: [what we do, in one sentence]
- **Key result**: [most compelling quantitative finding]
- **Implication**: [why it matters]
- **Estimated length**: 150-250 words
- **Self-contained check**: can a reader understand this without the paper?

### §1 Introduction
- **Opening hook**: [1-2 sentences that motivate the problem]
- **Gap**: [what's missing in prior work]
- **Key questions**: [the research questions this paper answers]
- **Contributions**: [numbered list, matching Claims-Evidence Matrix]
- **Hero figure**: [describe what Figure 1 should show — MUST include clear comparison if applicable]
- **Estimated length**: 1.5 pages
- **Key citations**: [3-5 papers to cite here]

### §2 Related Work
- **Subtopics**: [2-4 categories of related work]
- **Positioning**: [how this paper differs from each category]
- **Minimum length**: 1 full page (at least 3-4 paragraphs with substantive synthesis)
- **Must NOT be just a list** — synthesize, compare, and position

### §3 Method / Setup / Preliminaries
- **Notation**: [key symbols and their meanings]
- **Problem formulation**: [formal setup]
- **Method description**: [algorithm, model, or experimental design]
- **Formal statements**: [theorems, propositions if applicable]
- **Proof sketch locations**: [which key steps appear here vs. appendix]
- **Estimated length**: 1.5-2 pages

### §4 Experiments / Main Results
- **Figures planned**:
  - Fig 1: [description, type: bar/line/table/architecture, WHAT COMPARISON it shows]
  - Fig 2: [description]
  - Table 1: [what it shows, which methods/baselines compared]
- **Data source**: [which JSON files / experiment results]

### §5 Conclusion
- **Restatement**: [contributions rephrased, not copy-pasted from intro]
- **Limitations**: [honest assessment — reviewers value this]
- **Future work**: [1-2 concrete directions]
- **Estimated length**: 0.5 pages
```

### Step 4: Figure Plan

List every figure and table:

```markdown
## Figure Plan

| ID | Type | Description | Data Source | Priority |
|----|------|-------------|-------------|----------|
| Fig 1 | Hero/Architecture | System overview + comparison | manual | HIGH |
| Fig 2 | Line plot | Training curves comparison | figures/exp_A.json | HIGH |
| Fig 3 | Bar chart | Ablation results | figures/ablation.json | MEDIUM |
| Table 1 | Comparison table | Main results vs. baselines | figures/main_results.json | HIGH |
| Table 2 | Theory comparison | Prior bounds vs. ours | manual | HIGH (theory papers) |
```

**CRITICAL for Figure 1 / Hero Figure**: Describe in detail what the figure should contain, including:
- Which methods are being compared
- What the visual difference should demonstrate
- Caption draft that clearly states the comparison

### Step 5: Citation Scaffolding

For each section, list required citations:

```markdown
## Citation Plan
- §1 Intro: [paper1], [paper2], [paper3] (problem motivation)
- §2 Related: [paper4]-[paper10] (categorized by subtopic)
- §3 Method: [paper11] (baseline), [paper12] (technique we build on)
```

**Citation rules** (from claude-scholar + Imbad0202/academic-research-skills):
1. NEVER generate BibTeX from memory — always verify via search or existing .bib files
2. Every citation must be verified: correct authors, year, venue
3. Flag any citation you're unsure about with `[VERIFY]`
4. Prefer published versions over arXiv preprints when available

### Step 6: Cross-Review with REVIEWER_MODEL

Send the complete outline to Claude review for feedback:

```
mcp__claude-review__review_start:
  prompt: |
    Review this paper outline for a [VENUE] submission.
    [full outline including Claims-Evidence Matrix]

    Score 1-10 on:
    1. Logical flow — does the story build naturally?
    2. Claim-evidence alignment — every claim backed?
    3. Missing experiments or analysis
    4. Positioning relative to prior work
    5. Page budget feasibility (MAX_PAGES = main body to Conclusion end, excluding refs/appendix)

    For each weakness, suggest the MINIMUM fix.
    Be specific and actionable — "add X" not "consider more experiments".
```

After this start call, immediately save the returned `jobId` and poll `mcp__claude-review__review_status` with a bounded `waitSeconds` until `done=true`. Treat the completed status payload's `response` as the reviewer output, and save the completed `threadId` for any follow-up round.

Apply feedback before finalizing.

### Step 7: Output

Save the final outline to `docs/paper/PAPER_PLAN.md`:

```markdown
# Paper Plan

**Title**: [working title]
**Venue**: [target venue]
**Type**: [empirical/theory/method]
**Date**: [today]
**Page budget**: [MAX_PAGES] pages (main body to Conclusion end, excluding references & appendix)
**Section count**: [N] (must match the number of section files that will be created)

## Claims-Evidence Matrix
[from Step 1]

## Structure
[from Step 2-3, section by section]

## Figure Plan
[from Step 4, with detailed hero figure description]

## Citation Plan
[from Step 5]

## Reviewer Feedback
[from Step 6, summarized]

## Next Steps
[Choose exactly one block.]

### Manuscript entry gate PASSED
- [ ] /paper-figure to generate all figures
- [ ] /paper-write to draft LaTeX
- [ ] /paper-compile to build PDF

### Manuscript entry gate NOT PASSED
- [ ] Complete missing formal runs through /autodl-hpc or /experiment-plan
- [ ] Run /experiment-audit or complete docs/evidence/EVIDENCE_LEDGER.md
- [ ] Rerun /paper-plan after the evidence gate passes
```

## Output Protocols

> Follow these shared protocols for all output files:
> - **[Output Versioning Protocol](../../shared-references/output-versioning.md)** — write timestamped file first, then copy to fixed name
> - **[Output Manifest Protocol](../../shared-references/output-manifest.md)** — log every output to docs/project/OUTPUT_MANIFEST.md
> - **[Output Language Protocol](../../shared-references/output-language.md)** — respect the project's language setting

## Key Rules

- **No manuscript handoff without formal evidence** — if formal runs or the
  evidence audit are missing, stop at gap reporting and do not recommend
  `/paper-write`, `/paper-writing`, or LaTeX drafting.
- **Large file handling**: If the Write tool fails due to file size, immediately retry using Bash (`cat << 'EOF' > file`) to write in chunks. Do NOT ask the user for permission — just do it silently.

- **Do NOT generate author information** — leave author block as placeholder or anonymous
- **Be honest about evidence gaps** — mark claims as "needs experiment" rather than overclaiming
- **Page budget is hard** — if content exceeds MAX_PAGES, suggest what to move to appendix
- **MAX_PAGES counts main body only** — from first page to end of Conclusion. References and appendix are NOT counted.
- **Venue-specific norms** — all three venues (ICLR/NeurIPS/ICML) use `natbib` (`\citep`/`\citet`)
- **Claims-Evidence Matrix is the backbone** — every claim must map to evidence, every experiment must support a claim
- **Figures need detailed descriptions** — especially the hero figure, which must clearly specify comparisons and visual expectations
- **Section count is flexible** — 5-8 sections depending on paper type. Don't force content into a rigid 5-section template.

## Acknowledgements

Outline methodology inspired by [Research-Paper-Writing-Skills](https://github.com/Master-cai/Research-Paper-Writing-Skills) (claim-evidence mapping), [claude-scholar](https://github.com/Galaxy-Dawn/claude-scholar) (citation verification), and [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) (claim verification protocol).
