---
name: paper-figure
description: "Generate publication-quality figures and tables from experiment results. Use when user says \"画图\", \"作图\", \"generate figures\", \"paper figures\", or needs plots for a paper."
argument-hint: "[figure-plan-or-data-path]"
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, mcp__codex__codex, mcp__codex__codex-reply
---

# Paper Figure: Publication-Quality Plots from Experiment Data

Generate all figures and tables for a paper based on: **$ARGUMENTS**

## Scope: What This Skill Can and Cannot Do

| Category | Can auto-generate? | Examples |
|----------|-------------------|----------|
| **Data-driven plots** | ✅ Yes | Line plots (training curves), bar charts (method comparison), scatter plots, heatmaps, box/violin plots |
| **Comparison tables** | ✅ Yes | LaTeX tables comparing prior bounds, method features, ablation results |
| **Multi-panel figures** | ✅ Yes | Subfigure grids combining multiple plots (e.g., 3×3 dataset × method) |
| **Architecture/pipeline diagrams** | ✅ Partial | Prefer `/figure-spec` for deterministic SVG or TikZ/PGFPlots templates for publication-ready vector structure figures |
| **Generated image grids** | ❌ No — manual | Grids of generated samples (e.g., GAN/diffusion outputs). These come from running your model, not from this skill |
| **Photographs / screenshots** | ❌ No — manual | Real-world images, UI screenshots, qualitative examples |

**In practice:** For a typical ML paper, this skill handles ~60% of figures (all data plots + tables). The remaining ~40% (hero figure, architecture diagram, qualitative results) need to be created manually and placed in `figures/` before running `/paper-write`. The skill will detect these as "existing figures" and preserve them.

## Constants

- **STYLE = `publication`** — Visual style preset. Options: `publication` (default, clean for print), `poster` (larger fonts), `slide` (bold colors)
- **DPI = 300** — Output resolution
- **FORMAT = `pdf`** — Output format. Options: `pdf` (vector, best for LaTeX), `png` (raster fallback)
- **COLOR_PALETTE = `tab10`** — Default matplotlib color cycle. Options: `tab10`, `Set2`, `colorblind` (deuteranopia-safe)
- **FONT_SIZE = 10** — Base font size. Treat this as the paper body font size and keep all visible figure text at this size unless the venue style file proves otherwise.
- **FIG_DIR = `figures/`** — Output directory for generated figures
- **REVIEWER_MODEL = `gpt-5.5`** — Model used via Codex MCP for figure quality review.

## Inputs

1. **PAPER_PLAN.md** — figure plan table (from `/paper-plan`)
2. **Experiment data** — JSON files, CSV files, or screen logs in `figures/` or project root
3. **Existing figures** — any manually created figures to preserve

If no PAPER_PLAN.md exists, scan for data files and ask the user which figures to generate.

## Workflow

### Step 1: Read Figure Plan

Parse the Figure Plan table from PAPER_PLAN.md:

```markdown
| ID | Type | Description | Data Source | Priority |
|----|------|-------------|-------------|----------|
| Fig 1 | Architecture | ... | manual | HIGH |
| Fig 2 | Line plot | ... | figures/exp.json | HIGH |
```

Identify:
- Which figures can be auto-generated from data
- Which need manual creation (architecture diagrams, etc.)
- Which are comparison tables (generate as LaTeX)

### Step 2: Set Up Plotting Environment

Create a shared style configuration script. Prefer the local template
`templates/figure/matplotlib_publication_style.py`, which is a lightweight
adaptation of the reusable matplotlib habits from
`MLNLP-World/Paper-Picture-Writing-Code`.

```python
# paper_plot_style.py
from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib_publication_style import apply_paper_style, save_publication_figure

apply_paper_style(body_font_size_pt=FONT_SIZE, font_family='Times New Roman', dpi=DPI)
COLORS = plt.cm.tab10.colors

def save_fig(fig, name, fmt=FORMAT):
    save_publication_figure(fig, Path(FIG_DIR) / f'{name}.{fmt}')
    print(f'Saved: {FIG_DIR}/{name}.{fmt}')
```

If the target figure is better expressed in native LaTeX vector form, prefer a
PGFPlots/TikZ source that imports `templates/figure/pgfplots_bodyfont.tex`.
This keeps figures editable, vectorized, and aligned with the manuscript
typography.

### Step 3: Auto-Select Figure Type

Use this decision tree for data-driven figures (inspired by Imbad0202/academic-research-skills):

| Data Pattern | Recommended Type | Size |
|-------------|-----------------|------|
| X=time/steps, Y=metric | Line plot | 0.48\textwidth |
| Methods × 1 metric | Bar chart | 0.48\textwidth |
| Methods × multiple metrics | Grouped bar / radar | 0.95\textwidth |
| Two continuous variables | Scatter plot | 0.48\textwidth |
| Matrix / grid values | Heatmap | 0.48\textwidth |
| Distribution comparison | Box/violin plot | 0.48\textwidth |
| Multi-dataset results | Multi-panel (subfigure) | 0.95\textwidth |
| Prior work comparison | LaTeX table | — |

### Step 4: Generate Each Figure

For each figure in the plan, create a standalone Python script:

**Line plots** (training curves, scaling):
```python
# gen_fig2_training_curves.py
from paper_plot_style import *
import json

with open('figures/exp_results.json') as f:
    data = json.load(f)

fig, ax = plt.subplots(1, 1, figsize=(5, 3.5))
ax.plot(data['steps'], data['fac_loss'], label='Factorized', color=COLORS[0])
ax.plot(data['steps'], data['crf_loss'], label='CRF-LR', color=COLORS[1])
ax.set_xlabel('Training Steps')
ax.set_ylabel('Cross-Entropy Loss')
ax.legend(frameon=False)
save_fig(fig, 'fig2_training_curves')
```

**Bar charts** (comparison, ablation):
```python
fig, ax = plt.subplots(1, 1, figsize=(5, 3))
methods = ['Baseline', 'Method A', 'Method B', 'Ours']
values = [82.3, 85.1, 86.7, 89.2]
bars = ax.bar(methods, values, color=[COLORS[i] for i in range(len(methods))])
ax.set_ylabel('Accuracy (%)')
# Add value labels on bars
for bar, val in zip(bars, values):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3,
            f'{val:.1f}', ha='center', va='bottom', fontsize=FONT_SIZE-1)
save_fig(fig, 'fig3_comparison')
```

**Comparison tables** (LaTeX, for theory papers):
```latex
\begin{table}[t]
\centering
\caption{Comparison of estimation error bounds. $n$: sample size, $D$: ambient dim, $d$: latent dim, $K$: subspaces, $n_k$: modes.}
\label{tab:bounds}
\begin{tabular}{lccc}
\toprule
Method & Rate & Depends on $D$? & Multi-modal? \\
\midrule
\citet{MinimaxOkoAS23} & $n^{-s'/D}$ & Yes (curse) & No \\
\citet{ScoreMatchingdistributionrecovery} & $n^{-2/d}$ & No & No \\
\textbf{Ours} & $\sqrt{\sum n_k d_k / n}$ & No & Yes \\
\bottomrule
\end{tabular}
\end{table}
```

**Architecture/pipeline diagrams**:
- Default to `/figure-spec` when the diagram is structured and should remain deterministic/editable.
- Use TikZ/PGFPlots when the figure truly benefits from native LaTeX vector composition or must inherit the paper font metrics exactly.
- If a manual figure already exists in `figures/`, preserve it and generate only the LaTeX `\includegraphics` snippet.

### Step 5: Run All Scripts

```bash
# Run all figure generation scripts
for script in gen_fig*.py; do
    python "$script"
done
```

Verify all output files exist and are non-empty.

### Step 6: Generate LaTeX Include Snippets

For each figure, output the LaTeX code to include it:

```latex
% === Fig 2: Training Curves ===
\begin{figure}[t]
    \centering
    \includegraphics[width=0.48\textwidth]{figures/fig2_training_curves.pdf}
    \caption{Training curves comparing factorized and CRF-LR denoising.}
    \label{fig:training_curves}
\end{figure}
```

Save all snippets to `figures/latex_includes.tex` for easy copy-paste into the paper.

### Step 7: Figure Quality Review with REVIEWER_MODEL

Send figure descriptions and captions to GPT-5.4 for review:

```
mcp__codex__codex:
  model: gpt-5.5
  config: {"model_reasoning_effort": "xhigh"}
  prompt: |
    Review these figure/table plans for a [VENUE] submission.

    For each figure:
    1. Is the caption informative and self-contained?
    2. Does the figure type match the data being shown?
    3. Is the comparison fair and clear?
    4. Any missing baselines or ablations?
    5. Would a different visualization be more effective?

    [list all figures with captions and descriptions]
```

### Step 8: Quality Checklist

Before finishing, verify each figure (from pedrohcgs/claude-code-my-workflow):

- [ ] Font size readable at printed paper size (not too small)
- [ ] **Every visible word inside the figure matches the paper body font size** unless a venue-specific exception is documented
- [ ] Colors distinguishable in grayscale (print-friendly)
- [ ] **No title inside figures** — titles go only in LaTeX `\caption{}` (from pedrohcgs)
- [ ] Legend does not overlap data
- [ ] Axis labels have units where applicable
- [ ] Axis labels are publication-quality (not variable names like `emp_rate`)
- [ ] Figure width fits single column (0.48\textwidth) or full width (0.95\textwidth)
- [ ] PDF output is vector (not rasterized text)
- [ ] No matplotlib default title (remove `plt.title` for publications)
- [ ] Serif font matches paper body text (Times / Computer Modern)
- [ ] Colorblind-accessible (if using colorblind palette)

## Output

```
figures/
├── paper_plot_style.py          # shared style config
├── gen_fig1_architecture.py     # per-figure scripts
├── gen_fig2_training_curves.py
├── gen_fig3_comparison.py
├── fig1_architecture.pdf        # generated figures
├── fig2_training_curves.pdf
├── fig3_comparison.pdf
├── latex_includes.tex           # LaTeX snippets for all figures
└── TABLE_*.tex                  # standalone table LaTeX files
```

## Key Rules

- **Every figure must be reproducible** — save the generation script alongside the output
- **Do NOT hardcode data** — always read from JSON/CSV files
- **Use vector format (PDF)** for all plots — PNG only as fallback
- **Prefer template-backed plotting** — reuse `templates/figure/matplotlib_publication_style.py` or `templates/figure/pgfplots_bodyfont.tex` instead of ad hoc styles
- **No decorative elements** — no background colors, no 3D effects, no chart junk
- **Consistent style across all figures** — same fonts, colors, line widths
- **Typography lock** — any text inside the figure must default to the same point size as the manuscript body text
- **Colorblind-safe** — verify with https://davidmathlogic.com/colorblind/ if needed
- **One script per figure** — easy to re-run individual figures when data changes
- **No titles inside figures** — captions are in LaTeX only
- **Comparison tables count as figures** — generate them as standalone .tex files

## Figure Type Reference

| Type | When to Use | Typical Size |
|------|------------|--------------|
| Line plot | Training curves, scaling trends | 0.48\textwidth |
| Bar chart | Method comparison, ablation | 0.48\textwidth |
| Grouped bar | Multi-metric comparison | 0.95\textwidth |
| Scatter plot | Correlation analysis | 0.48\textwidth |
| Heatmap | Attention, confusion matrix | 0.48\textwidth |
| Box/violin | Distribution comparison | 0.48\textwidth |
| Architecture | System overview | 0.95\textwidth |
| Multi-panel | Combined results (subfigures) | 0.95\textwidth |
| Comparison table | Prior bounds vs. ours (theory) | full width |

## Acknowledgements

Design pattern (type × style matrix) inspired by [baoyu-skills](https://github.com/jimliu/baoyu-skills). Publication style defaults and figure rules from [pedrohcgs/claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow). Visualization decision tree from [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills).
