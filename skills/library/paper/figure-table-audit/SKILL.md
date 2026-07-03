---
name: figure-table-audit
description: "Audit whether paper figures and tables are submission-ready: referenced in the text, ordered correctly, readable, stylistically consistent, and venue-appropriate. Use when the user wants to check figure/table quality, caption quality, vector/raster risks, or final paper visuals before submission."
argument-hint: "[paper-dir-or-main.tex]"
allowed-tools: Bash(*), Read, Grep, Glob, Write, Edit
---

# Figure Table Audit

Audit paper figures and tables for submission quality without rewriting the
entire manuscript.

## Load First

Read `../../shared-references/paper-writing-rules.md`,
`../../shared-references/writing-principles.md`, and
`../../shared-references/venue-checklists.md`.

Focus on the `Figures` and `Tables` rules from the shared reference.

## Inputs

- `paper/` directory by default
- `main.tex` plus included section files
- `figures/` and any figure/table include snippets

## Checks

1. Every figure and table is referenced in the text.
2. Reference order matches figure/table numbering order.
3. Captions are self-contained and use venue-appropriate capitalization.
4. Plot assets prefer vector formats where appropriate.
5. Figure text, symbols, and notation are consistent with the manuscript.
6. Colors and line styles remain readable at paper scale.
7. Tables follow `booktabs`-style presentation and avoid noisy vertical rules.
8. Any obvious Type 3 font or export-risk note is surfaced.

## Output

Write a concise `docs/paper/FIGURE_TABLE_AUDIT.md` with:

- `blocking`: must-fix submission issues
- `warnings`: quality or readability issues
- `optional`: polish suggestions

Keep the file short. Do not generate a giant visual QA report.

## Rules

- Do not invent figure interpretations or missing captions.
- If a figure requires human visual inspection, say so explicitly.
- If the figure set is clearly incomplete, recommend rerunning `/paper-figure`
  or adding the missing manual figure before manuscript finalization.

## See Also

- `/paper-figure`
- `/paper-write`
- `/paper-compile`
