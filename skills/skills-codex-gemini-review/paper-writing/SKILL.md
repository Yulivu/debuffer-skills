---
name: "paper-writing"
description: "Prompt-only by default in the lightweight pack; Claude/Gemini reviewer transport is explicit opt-in. Workflow 3: evidence-gated paper writing pipeline. Requires audited formal experiment evidence and an accepted paper plan before manuscript drafting. If only smoke, pilot, toy, or validation results exist, stop and produce next actions or a gap report. Use when user says \\\"\u5199\u8bba\u6587\u5168\u6d41\u7a0b\\\", \\\"write paper pipeline\\\", \\\"\u4ece\u62a5\u544a\u5230PDF\\\", \\\"paper writing\\\", or wants complete paper generation from audited evidence."
---

> Override for Codex users who want **Gemini**, not a second Codex agent, to act as the reviewer. Install this package **after** `skills/skills-codex/*`.

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

# Workflow 3: Evidence-Gated Paper Writing Pipeline

Orchestrate an evidence-gated paper writing workflow for: **$ARGUMENTS**

## Overview

This skill chains five sub-skills into a single automated pipeline:

```
/paper-plan → /paper-figure → /paper-write → /paper-compile → /auto-paper-improvement-loop
  (outline)     (plots)        (LaTeX)        (build PDF)       (review & polish ×2)
```

Each phase builds on the previous one's output. The final deliverable is a polished, reviewed `paper/` directory with LaTeX source and compiled PDF.

Default manuscript package target follows
`../../skills-codex/shared-references/icde-yu-memory-paper-structure.md`.
For new IEEE/Overleaf starts, prefer thin `main.tex`, `Content/`, `Figure/`,
and `IEEE.bib`; preserve `sections/`, `figures/`, and `references.bib` for
existing projects.

## Constants

- **VENUE = `ICLR`** — Target venue. Options: `ICLR`, `NeurIPS`, `ICML`. Affects style file, page limit, citation format.
- **MAX_IMPROVEMENT_ROUNDS = 1** — Number of review→fix→recompile rounds in the improvement loop.
- **REVIEWER_MODEL = `gemini-review`** — Gemini reviewer invoked through the local `gemini-review` MCP bridge for plan review, figure review, writing review, and the improvement loop.
- **AUTO_PROCEED = false** — Pause between phases unless the user explicitly opts into auto-continue.
- **HUMAN_CHECKPOINT = true** — Pause after each improvement review so the user can inspect the score and provide custom modification instructions. Passed through to `/auto-paper-improvement-loop`.

> Override inline: `/paper-writing "NARRATIVE_REPORT.md" — venue: NeurIPS, human checkpoint: true`

## Inputs

This pipeline accepts one of:

1. **Accepted `docs/paper/PAPER_PLAN.md` plus audited formal evidence** — best.
2. **`NARRATIVE_REPORT.md` plus audited formal evidence** — allowed only if the
   entry gate passes.
3. **Research direction + validation results** — not enough for manuscript
   drafting; produce `docs/project/NEXT_ACTIONS.md` or `docs/paper/GAP_REPORT.md`
   and stop.

The more detailed the input (especially figure descriptions and quantitative results), the better the output.

## Pipeline

### Phase 0: Manuscript Entry Gate

Before Phase 1, inspect `PROJECT_STATUS.md`, `docs/project/BLUEPRINT_GATE.md`,
`docs/paper/PAPER_PLAN.md`, `docs/evidence/EVIDENCE_LEDGER.md`,
`CLAIMS_FROM_RESULTS.md`, `docs/experiments/EXPERIMENT_LOG.md`, and raw result
folders when present.

Proceed only if formal runs exist, raw evidence is auditable, and
`docs/evidence/EVIDENCE_LEDGER.md` / `CLAIMS_FROM_RESULTS.md` maps claims to raw
evidence and unresolved gaps. If any check fails, stop before Phase 1. Do not
create `paper/`, LaTeX section files, or `docs/paper/PAPER_GUIDE.md`; write
`docs/project/NEXT_ACTIONS.md` or `docs/paper/GAP_REPORT.md` instead.

Smoke, pilot, toy, or validation runs never satisfy this gate.

### Phase 1: Paper Plan

Invoke `/paper-plan` to create the structural outline:

```
/paper-plan "$ARGUMENTS"
```

**What this does:**
- Parse NARRATIVE_REPORT.md for claims, evidence, and figure descriptions
- Build a **Claims-Evidence Matrix** — every claim maps to evidence, every experiment supports a claim
- Design section structure (5-8 sections depending on paper type)
- Plan figure/table placement with data sources
- Scaffold citation structure
- Gemini reviews the plan for completeness via the `/paper-plan` overlay

**Output:** `PAPER_PLAN.md` with section plan, figure plan, citation scaffolding.

**Checkpoint:** Present the plan summary to the user.

```
📐 Paper plan complete:
- Title: [proposed title]
- Sections: [N] ([list])
- Figures: [N] auto-generated + [M] manual
- Target: [VENUE], [PAGE_LIMIT] pages

Shall I proceed with figure generation?
```

- **User approves** (or AUTO_PROCEED=true) → proceed to Phase 2.
- **User requests changes** → adjust plan and re-present.

### Phase 2: Figure Generation

Invoke `/paper-figure` to generate data-driven plots and tables:

```
/paper-figure "PAPER_PLAN.md"
```

**What this does:**
- Read figure plan from PAPER_PLAN.md
- Generate matplotlib/seaborn plots from JSON/CSV data
- Generate LaTeX comparison tables
- Create `figures/latex_includes.tex` for easy insertion
- Gemini reviews figure quality and captions via the `/paper-figure` overlay

**Output:** `figures/` directory with PDFs, generation scripts, and LaTeX snippets.

#### Phase 2b: AI Illustration Generation (when `illustration: true`)

**Skip this step entirely if `illustration` is not set or is `false`.**

If the paper plan includes architecture diagrams, pipeline figures, or method illustrations, invoke `/paper-illustration`:

```
/paper-illustration "[method description from PAPER_PLAN.md or NARRATIVE_REPORT.md]"
```

**What this does:**
- Codex plans the layout → Gemini optimizes → Nano Banana Pro renders → Codex reviews (score ≥ 9)
- Output: `figures/ai_generated/*.png` — publication-quality method diagrams
- Requires `GEMINI_API_KEY` environment variable

> **Without `illustration: true`:** Architecture diagrams must still be created manually (draw.io, Figma, TikZ) and placed in `figures/` before proceeding — same as before.

**Checkpoint:** List generated vs manual figures.

```
📊 Figures complete:
- Data plots (auto): [list]
- AI illustrations (auto): [list, if illustration: true]
- Manual (need your input): [list]
- LaTeX snippets: figures/latex_includes.tex

[If manual figures needed]: Please add them to figures/ before I proceed.
[If all auto]: Shall I proceed with LaTeX writing?
```

### Phase 3: LaTeX Writing

Invoke `/paper-write` to generate section-by-section LaTeX:

```
/paper-write "PAPER_PLAN.md"
```

**What this does:**
- Write each section following the plan, with proper LaTeX formatting
- Insert figure/table references from `figures/latex_includes.tex`
- Build `references.bib` from citation scaffolding
- Clean stale files from previous section structures
- Automated bib cleaning (remove uncited entries)
- De-AI polish (remove "delve", "pivotal", "landscape"...)
- Gemini reviews each section for quality via the `/paper-write` overlay

**Output:** `paper/` directory with `main.tex`, `sections/*.tex`, `references.bib`, `math_commands.tex`.

**Checkpoint:** Report section completion.

```
✍️ LaTeX writing complete:
- Sections: [N] written ([list])
- Citations: [N] unique keys in references.bib
- Stale files cleaned: [list, if any]

Shall I proceed with compilation?
```

### Phase 4: Compilation

Invoke `/paper-compile` to build the PDF:

```
/paper-compile "paper/"
```

**What this does:**
- `latexmk -pdf` with automatic multi-pass compilation
- Auto-fix common errors (missing packages, undefined refs, BibTeX syntax)
- Up to 3 compilation attempts
- Post-compilation checks: undefined refs, page count, font embedding
- Precise page verification via `pdftotext`
- Stale file detection

**Output:** `paper/main.pdf`

**Checkpoint:** Report compilation results.

```
🔨 Compilation complete:
- Status: SUCCESS
- Pages: [X] (main body) + [Y] (references) + [Z] (appendix)
- Within page limit: YES/NO
- Undefined references: 0
- Undefined citations: 0

Shall I proceed with the improvement loop?
```

### Phase 5: Auto Improvement Loop

Invoke `/auto-paper-improvement-loop` to polish the paper:

```
/auto-paper-improvement-loop "paper/"
```

**What this does (2 rounds):**

**Round 1:** Gemini reviews the full paper → identifies CRITICAL/MAJOR/MINOR issues → Codex implements fixes → recompile → save `main_round1.pdf`

**Round 2:** Gemini re-reviews with conversation context → identifies remaining issues → Codex implements fixes → recompile → save `main_round2.pdf`

**Typical improvements:**
- Fix assumption-model mismatches
- Soften overclaims to match evidence
- Add missing interpretations and notation
- Strengthen limitations section
- Add theory-aligned experiments if needed

**Output:** Three PDFs for comparison + `PAPER_IMPROVEMENT_LOG.md`.

**Format check** (included in improvement loop Step 8): After final recompilation, auto-detect and fix overfull hboxes (content exceeding margins), verify page count vs venue limit, and ensure compact formatting. Any overfull > 10pt is fixed before generating the final PDF.

### Phase 6: Final Report

```markdown
# Paper Writing Pipeline Report

**Input**: [NARRATIVE_REPORT.md or topic]
**Venue**: [ICLR/NeurIPS/ICML]
**Date**: [today]

## Pipeline Summary

| Phase | Status | Output |
|-------|--------|--------|
| 1. Paper Plan | ✅ | PAPER_PLAN.md |
| 2. Figures | ✅ | figures/ ([N] auto + [M] manual) |
| 3. LaTeX Writing | ✅ | paper/sections/*.tex ([N] sections, [M] citations) |
| 4. Compilation | ✅ | paper/main.pdf ([X] pages) |
| 5. Improvement | ✅ | [score0]/10 → [score2]/10 |

## Improvement Scores

For ICDE-style IEEE/Overleaf drafts, interpret `paper/sections/*.tex` in the
summary above as `paper/Content/*.tex`, and `references.bib` as `IEEE.bib`.

| Round | Score | Key Changes |
|-------|-------|-------------|
| Round 0 | X/10 | Baseline |
| Round 1 | Y/10 | [summary] |
| Round 2 | Z/10 | [summary] |

## Deliverables
- paper/main.pdf — Final polished paper
- paper/main_round0_original.pdf — Before improvement
- paper/main_round1.pdf — After round 1
- paper/main_round2.pdf — After round 2
- paper/PAPER_IMPROVEMENT_LOG.md — Full review log

## Remaining Issues (if any)
- [items from final review that weren't addressed]

## Next Steps
- [ ] Visual inspection of PDF
- [ ] Add any missing manual figures
- [ ] Submit to [venue] via OpenReview / CMT / HotCRP
```

## Output Protocols

> Follow these shared protocols for all output files:
> - **[Output Versioning Protocol](../../shared-references/output-versioning.md)** — write timestamped file first, then copy to fixed name
> - **[Output Manifest Protocol](../../shared-references/output-manifest.md)** — log every output to docs/project/OUTPUT_MANIFEST.md
> - **[Output Language Protocol](../../shared-references/output-language.md)** — respect the project's language setting
> - Note: paper content is always written in English regardless of project language setting.

## Key Rules

- **Large file handling**: If the Write tool fails due to file size, immediately retry using Bash (`cat << 'EOF' > file`) to write in chunks. Do NOT ask the user for permission — just do it silently.

- **Don't skip phases.** Each phase builds on the previous one — skipping leads to errors.
- **Checkpoint between phases** when AUTO_PROCEED=false. Present results and wait for approval.
- **Manual figures first.** If the paper needs architecture diagrams or qualitative results, the user must provide them before Phase 3.
- **Compilation must succeed** before entering the improvement loop. Fix all errors first.
- **Preserve all PDFs.** The user needs round0/round1/round2 for comparison.
- **Document everything.** The pipeline report should be self-contained.
- **Respect page limits.** If the paper exceeds the venue limit, suggest specific cuts before the improvement loop.

## Composing with Other Workflows

```
/idea-discovery "direction"                  -> find/refine ideas
/research-blueprint                          -> freeze theory, method, and experiment gates
/autodl-hpc or /experiment-plan              -> formal runs, not local heavy compute
/experiment-audit or evidence ledger update  -> map formal results to claims
/paper-plan "docs/paper/NARRATIVE_REPORT.md" -> plan only after evidence gate passes
/paper-writing "docs/paper/PAPER_PLAN.md"    -> draft only after manuscript entry gate passes

If the project has only smoke, pilot, toy, or validation results, stay in the
experiment/audit phases and do not run this skill.
```

## Typical Timeline

| Phase | Duration | Can sleep? |
|-------|----------|------------|
| 1. Paper Plan | 5-10 min | No |
| 2. Figures | 5-15 min | No |
| 3. LaTeX Writing | 15-30 min | Yes ✅ |
| 4. Compilation | 2-5 min | No |
| 5. Improvement | 15-30 min | Yes ✅ |

**Total: ~45-90 min** for a full paper from narrative report to polished PDF.
