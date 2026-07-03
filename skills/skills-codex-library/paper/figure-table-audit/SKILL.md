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

Read `../../skills-codex/shared-references/paper-writing-rules.md`,
`../../skills-codex/shared-references/writing-principles.md`, and
`../../skills-codex/shared-references/venue-checklists.md`.

Use the `Figures` and `Tables` sections as the primary ruleset.

## Scope

- Check references to `Figure~\ref{...}` and `Table~\ref{...}`
- Check numbering order vs first textual mention
- Check caption quality and obvious formatting mismatches
- Check file formats in `figures/`
- Check whether generated plots and tables look internally consistent on paper

## Output

Write `docs/paper/FIGURE_TABLE_AUDIT.md` with only:

- blocking
- warnings
- optional

Keep it concise and actionable.

## See Also

- `/paper-figure`
- `/paper-write`
- `/paper-compile`
