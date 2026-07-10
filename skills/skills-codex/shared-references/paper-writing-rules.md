# Paper Writing Rules

Use this reference when planning, drafting, compiling, or auditing a paper.
It condenses recurring submission-time writing rules into one place so the
paper workflow can stay consistent without generating long side documents.

## When to Load

- `paper-plan`: load the `Structure`, `Introduction`, and `Experiments`
  sections before freezing the outline.
- `paper-write`: load the `Style`, `Citations`, `Math`, `Figures`, and
  `Tables` sections while drafting.
- `paper-compile`: load the `Submission` and `Anonymity` sections during the
  final pre-submit check.
- `figure-table-audit`: load `Figures` and `Tables`.
- `experiment-writeup-audit`: load `Experiments`.

## Submission

- Keep a versioned backup before the deadline; do not rely only on Overleaf.
- Keep title and abstract consistent with the submission system metadata.
- Check venue page limits precisely: main body vs references vs appendix rules
  differ by venue.
- Keep the camera-ready / anonymous metadata block aligned with the target
  venue template.
- Do not change figure sizes casually at the very end just to squeeze pages.
- After submission, keep monitoring the venue site and registered email for
  deadline, policy, or rebuttal updates.

## Anonymity

- Anonymous submissions must not expose author names, affiliations, emails,
  acknowledgements, or repository paths that reveal identity.
- Avoid self-revealing phrasing such as `our previous work` when the citation
  makes authorship obvious.
- Anonymous code or data releases must not use personal GitHub, Dropbox, or
  Google Drive links.
- Remove hard-coded usernames, institution paths, tokens, and hidden VCS
  directories from supplementary code packages.

## Structure

- A paper is not only a log of what was done; it must explain why the problem
- matters, why it is hard, and why the proposed solution is necessary.
- For each section or subsection, state the motivation before the mechanism:
  `why` before `how`.
- Every claim must have support from prior work, theorem/proof, or experiment.
- Unsupported claims are liabilities and should be deleted or downgraded.
- For IEEE/Overleaf-style two-column papers, keep Related Work and Conclusion
  compact by default. Together they should not exceed about 0.8 page unless the
  target venue or user explicitly asks for an extended survey.

## Introduction

Recommended flow:

1. Big-picture background and problem importance.
2. Concrete problem statement and difficulty.
3. Current research status and the main limitation of existing approaches.
4. What an ideal solution needs and what challenges remain.
5. Brief overview of the proposed method and why it helps.
6. Contributions and strongest empirical/theoretical takeaways.
7. Optional paper roadmap if space allows.

Rules:

- Keep Introduction focused on value and logic, not implementation detail.
- Put detailed mechanism explanations in the method section.
- Contributions should be specific and falsifiable, not generic promises.

## Style

- Prefer calibrated wording over absolute wording.
- Prefer `straightforward` over `obvious`.
- Prefer `generally`, `usually`, or `often` over `always`.
- Prefer `rare` over `never` unless literally impossible.
- Prefer `alleviate` or `relieve` over `eliminate` unless fully justified.
- Keep the final line of a paragraph from degenerating into a single dangling
  word or tiny fragment when practical.
- In two-column papers, do not leave a paragraph as a solid block that nearly
  fills a whole column. Split long paragraphs into motivation, evidence, and
  takeaway paragraphs, or use compact `\paragraph{...}` structure where the
  venue style supports it.
- Run an anti-defensive writing pass before finalizing prose. Lead with the
  claim, result, or scope instead of explaining what the paper does not claim,
  does not prove, or does not cover.
- Keep real limitations only when they affect validity, evidence
  interpretation, scope of application, research design, or correct reader use.
  State them once, calmly, in Methods, Discussion, Limitations, or another
  appropriate section.
- Avoid putting defensive caveats in high-impact positions: title, abstract,
  contribution paragraphs, paragraph openings, conclusion openings, and figure
  captions.
- Replace vague hedges (`may`, `could`, `potentially`) with precise evidence
  strength and scope. If uncertainty is real, name its source.
- Convert negative scope to positive scope: write what the paper examines,
  tests, explains, or contributes rather than reflexive `we do not claim...`.
- Avoid unnecessary patterns such as `to be clear`, `it is worth noting`,
  `not X but Y`, `this should not be taken to mean`, and repeated limitation
  setup unless the contrast is part of the argument.

## LaTeX

- Keep each major section in a separate `.tex` file when the project is large.
- Use consistent naming for section files and paper versions.
- For `e.g.`, `i.e.`, `etc.`, and `et al.`, use consistent macros or enforce
  the final comma style required by the venue.
- Use correct TeX quotes rather than raw straight quotes.
- Keep spacing after brackets and macros deliberate; use `~` when the token
  must stay attached.
- Use `enumitem` with explicit margins instead of ad hoc list spacing hacks.

## Section Titles

- Section and subsection capitalization must match venue norms.
- Captions usually use sentence-style capitalization and end with a period.

## Citations

- Leave a nonbreaking space before `\cite{...}`.
- Use Google Scholar or another verified source only to fetch real BibTeX;
  do not handwrite bibliographic metadata from memory.
- For final paper bibliographies, default to published conference or journal
  versions. Treat arXiv as a discovery source only; do not add arXiv entries to
  the final `.bib` unless the user explicitly accepts an unpublished preprint
  exception because no formal version exists.
- Avoid excessive self-citation in double-blind submissions.
- Related work should synthesize categories, then explain the limitation of
  those lines and the relative advantage of this paper.
- Do not make a bare citation the grammatical subject of a sentence.

## Math

- Use inline `$...$` for math inside prose.
- Do not leave unused symbols defined in the paper.
- The same symbol should not represent multiple concepts.
- Every newly introduced symbol must be explained.
- Prefer consistent conventions for matrices, vectors, scalars, subscripts, and
  dimensions.
- Multi-line equations should align cleanly.
- Keep a cross-section notation ledger for long papers: macros in
  `math_commands.tex`, symbol definitions in prose, equation labels, theorem
  restatements, and appendix notation must agree. Run
  `/paper-math-consistency-audit` before submission when formulas or formal
  notation appear in the manuscript.

## Figures

- Every figure must be referenced in the paper text.
- Figure order should match the order of first mention.
- Keep the figure close to where it is discussed when possible.
- Prefer vector outputs such as PDF/EPS/SVG over raster outputs for plots.
- Figure text must remain readable at paper scale and in grayscale when needed.
- Keep symbols, fonts, and notation consistent with the main text.
- Avoid weak low-contrast colors.
- Avoid Type 3 fonts in exported figures.
- Architecture or workflow figures should be manually checked even if generated
  by a helper.

## Tables

- Every table must be referenced in the paper text.
- Table order should match the order of first mention.
- Keep tables close to their discussion when possible.
- Prefer `booktabs` style and avoid vertical rules.
- Use consistent decimal precision and alignment.

## Experiments

- Experimental settings should explicitly cover datasets, splits, metrics,
  implementation details, hardware, seeds, baselines, and backbones.
- Baselines should include recent strong methods when relevant.
- Typical experiment families include:
  overall performance, ablation, parameter analysis, efficiency,
  compatibility, transferability, case study, and feature analysis.
- Overall-performance discussion must explain causes, not just report numbers.
- Numbers used in analysis sections must stay aligned with the main results
  tables and figures.
