---
name: paper-visualization
description: "Route paper figure work to the right lightweight path and enforce manuscript-grade visual rules. Use when user says \"论文作图\", \"补图\", \"论文可视化\", \"画论文图\", \"paper visualization\", \"figure pipeline\", or wants one entry point for plots, architecture figures, and figure audits."
argument-hint: "[paper-plan-or-figure-request]"
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Skill
---

# Paper Visualization

## Capability Routing

This is a first-layer entry skill. Keep it loaded as the user-facing route; when a request needs a specialized capability below, resolve the debuffer repo root from `.debuffer_skills/installed-skills-codex.txt` (`repo_root`) when available, read the referenced library `SKILL.md`, then follow that skill. Do not copy the whole library skill into this file.

- `/paper-figure`: read `../library/paper/paper-figure/SKILL.md`.
- `/figure-spec`: read `../library/paper/figure-spec/SKILL.md`.
- `/image-to-vector-ppt`: read `../library/paper/image-to-vector-ppt/SKILL.md`.
- `/figure-table-audit`: read `../library/paper/figure-table-audit/SKILL.md`.
- `/mermaid-diagram`: read `../library/paper/mermaid-diagram/SKILL.md`.
- `/render-html`: read `../library/paper/render-html/SKILL.md`.
- `/paper-illustration`: read `../library/paper/paper-illustration/SKILL.md`.
- `/paper-figure-artifact-audit`: read `../library/paper/paper-figure-artifact-audit/SKILL.md`.


Route paper-figure work for: **$ARGUMENTS**

This is a lightweight orchestration skill. It does not replace the existing
renderers. It decides which skill should own each figure and applies one shared
publication rule set before any drawing starts.

## Shared Rules

- **Body-font lock**: any visible text inside a figure must match the paper
  body font size unless the venue explicitly requires a documented exception.
- **Vector first**: prefer PDF / SVG / native LaTeX vector output over raster.
- **No title inside figure**: titles belong in captions, not inside the image.
- **Reproducible artifacts**: save the generating script/spec next to the
  output.
- **Local-lightweight default**: do not invent heavyweight GUI workflows when
  `paper-figure`, `figure-spec`, or template-backed LaTeX/matplotlib can do the
  job.

## Default Routing

Choose the narrowest route that matches the requested figure:

1. **Data plots and result figures**  
   Use `/paper-figure`.
   Typical cases: line/bar/scatter/heatmap/box plots, ablations, scaling
   curves, comparison tables, multi-panel result figures.

2. **Architecture / workflow / system / pipeline diagrams**  
   Use `/figure-spec` first.
   Choose this when layout is structured and should stay deterministic,
   editable, and easy to revise.

3. **Native LaTeX vector figures**  
   Stay in the project with PGFPlots/TikZ when:
   - the figure should inherit manuscript typography exactly,
   - the figure is best expressed as axis-based LaTeX graphics,
   - or the target venue is sensitive to font consistency.
   Prefer:
   - `templates/figure/matplotlib_publication_style.py`
   - `templates/figure/pgfplots_bodyfont.tex`

4. **Qualitative concept illustrations**  
   Use `/paper-illustration` or `/paper-illustration-image2` only when the
   figure is not naturally expressed as data plots or deterministic diagrams.

5. **Simple temporary flowcharts**  
   Use `/mermaid-diagram` only for low-stakes drafts, planning, or quick visual
   communication. Do not treat Mermaid as the default for submission figures.

6. **Submission-quality check**  
   After generation, run `/figure-table-audit` on the final figure set.

## Triage Procedure

When a user asks for "paper figures" without enough detail:

1. Read `PAPER_PLAN.md`, `paper/`, `figures/`, and any existing figure plan.
2. Build a compact figure inventory:
   - figure id
   - purpose / claim supported
   - preferred route
   - status: existing / generate / revise / audit
3. Generate only the missing or weak figures first.
4. Audit before handing the figure set to `/paper-write` or `/paper-writing`.

## Practical Defaults

- For plots, prefer the style habits adapted from
  `MLNLP-World/Paper-Picture-Writing-Code`, but normalized through
  `templates/figure/matplotlib_publication_style.py`.
- For PGFPlots/TikZ, import `templates/figure/pgfplots_bodyfont.tex` and keep
  the figure text size equal to manuscript body text.
- For architecture figures, prefer `/figure-spec` over ad hoc draw.io-style
  manual work unless the user explicitly asks for a manual editing workflow.

## Output

Produce a compact decision record in the working notes or response:

```text
Figure inventory:
- Fig 1: architecture overview -> /figure-spec -> generate
- Fig 2: main results bar chart -> /paper-figure -> generate
- Fig 3: ablation heatmap -> /paper-figure -> revise
- Table 1: benchmark comparison -> /paper-figure -> generate

Global rules:
- figure text size = paper body text size
- vector-first export
- final pass: /figure-table-audit
```

## Completion Rule

Do not stop at "use skill X". Either:
- invoke the downstream skill immediately, or
- if the user asked only for process guidance, return the routed figure plan
  and the typography/export constraints.
