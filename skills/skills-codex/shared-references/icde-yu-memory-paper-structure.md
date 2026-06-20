# ICDE_YU_Memory Paper Structure

Use this reference as the default structural contract for new Overleaf or
LaTeX paper drafts, especially IEEE-style conference/journal papers and
systems, memory, query-processing, benchmark, or data-engineering papers.

## Observed Reference Package

The inspected reference at `D:/download/ICDE_YU_Memory` uses:

- Root files: `main.tex`, `IEEEtran.cls`, `IEEE.bib`.
- Section directory: `Content/`.
- Figure directory: `Figure/`.
- Figure assets as PDFs, referenced as `Figure/figureN.pdf`.
- `main.tex` as a thin entrypoint: preamble, title/author block, abstract,
  keywords, ordered `\input{Content/...}` calls, and IEEE bibliography.
- IEEE stack: `\documentclass[conference]{IEEEtran}`, `cite`,
  `amsmath/amssymb/amsfonts`, `algorithmic`, `graphicx`, `xcolor`,
  `colortbl`, `booktabs`, `enumitem`, and `microtype`.

## Default Overleaf Layout

For new IEEE/Overleaf starts, prefer this layout unless the target venue's
official package requires different names:

```text
paper/
  main.tex
  IEEEtran.cls
  IEEE.bib
  Content/
    1.Introduction.tex
    2.Methodology.tex
    3.BenchmarkConstruction.tex
    4.Experiment.tex
    5.Discussion.tex
    6.RelatedWork.tex
    7.Conclusion.tex
  Figure/
    figure1.pdf
    figure2.pdf
    figure3.pdf
```

Keep `main.tex` declarative. It should not contain long section prose except
front matter that the venue template naturally keeps in the main file
(title, author block, abstract, keywords).

For existing non-IEEE projects that already use `sections/`, `figures/`, and
`references.bib`, preserve that convention instead of renaming files solely
for style.

## Section Topology

Default order for systems, memory, benchmark, and query-processing papers:

1. Introduction
2. Methodology / Data Model
3. Benchmark or Dataset Construction when it is contribution-bearing
4. Experiments / Results
5. Discussion when limitations, trade-offs, scope, or failure modes need space
6. Related Work
7. Conclusion

Do not force Related Work before Methodology for these papers. Placing Related
Work after experiments is acceptable when the technical story reads better:
problem, model, evaluation, then positioning.

## Introduction Pattern

Use the reference's argumentative flow:

1. Introduce the data/problem setting concretely.
2. Explain why the setting is hard, not just why it is popular.
3. Show where existing approaches fail.
4. State design requirements or desiderata.
5. Present the proposed system/framework.
6. End with 3-4 falsifiable contributions.

Contribution bullets should map to the later paper structure: problem
perspective, data model/semantics, system or query-processing framework, and
empirical study.

## Methodology Pattern

Use explicit substructure instead of a single method block. Good subsection
types include:

- Problem Formulation
- Data Model or Temporal Evidence Graph
- Offline Construction
- Validity Semantics
- Online Query Processing
- Context Assembly / Answer Planning
- Evidence Tracing / Interpretability

Use `\paragraph{...}` for compact step-level structure inside a subsection.
For process papers, name steps explicitly, e.g. `Step 1: Session-level event
distillation`.

## Experiment Pattern

Open experiments with research questions before setup:

```latex
\begin{itemize}[leftmargin=*]
\item \textbf{RQ1:} ...
\item \textbf{RQ2:} ...
\end{itemize}
```

Then organize as:

- Experimental Setup: datasets, special benchmarks/stress tests, baselines,
  backbones, metrics, implementation details.
- Main Results: answer RQ1/RQ2 with main tables first.
- Ablation Study: answer component questions with compact summary tables and
  visual impact plots.
- Special slices or stress tests: update-heavy, robustness, scale, or other
  targeted diagnostics.
- Efficiency or construction cost analysis.
- Interpretability or qualitative trace analysis when the method exposes
  evidence paths or explanations.

Every result paragraph should name the RQ or claim it supports.

## Figure and Table Pattern

For system/memory papers, plan at least:

- Figure 1: offline/construction overview.
- Figure 2: online/query-time pipeline.
- Main result table(s), often by benchmark, backbone, and question type.
- Ablation summary table or impact heatmap/bar plot.
- Qualitative/interpretability figure if the method claims traceability.

Use wide `table*`/`figure*` for dense IEEE two-column comparisons. Keep
captions descriptive enough that a skim reader understands the claim.

## Bibliography and Compile Rules

- Use `IEEE.bib` and `\bibliographystyle{IEEEtran}` for new IEEE/Overleaf
  drafts following this structure.
- Use numeric `\cite{}` with the `cite` package for IEEE; do not mix natbib
  commands into IEEE manuscripts.
- Keep bibliography entries limited to cited papers.
- Ensure compile and packaging tools recognize both layouts:
  `Content/` or `sections/`, `Figure/` or `figures/`, `IEEE.bib` or
  `references.bib`.
