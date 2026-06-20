---
name: paper-math-consistency-audit
description: Audit a LaTeX paper for cross-section math, formula, notation, macro, equation-label, and appendix restatement consistency. Use when a paper has formulas, notation, math_commands.tex, theorem-like statements, appendix derivations, or when the user asks to check formula consistency, notation drift, symbol reuse, equation references, or long-running paper-writing continuity before submission.
argument-hint: "[paper-directory]"
allowed-tools: Bash(*), Read, Write, Grep, Glob
---

# Paper Math Consistency Audit

Audit math and notation consistency for: **$ARGUMENTS**

This skill is a manuscript integrity check, not a proof-validity checker. It
does not decide whether proofs are mathematically correct; use `/proof-checker`
for proof soundness. This skill checks whether the paper says the same thing
about symbols, macros, equations, and restated statements across files.

## Inputs

Accept a paper directory, usually `paper/`. Discover these files:

- `main.tex`
- section files under `Content/`, `sections/`, `sec/`, or files directly
  `\input`ed / `\include`d by `main.tex`
- appendix files under the same section directories
- `math_commands.tex`, `macros.tex`, or other macro files included by
  `main.tex`
- bibliography is not required

If no math-like content is present, still emit `MATH_CONSISTENCY_AUDIT.json`
with verdict `NOT_APPLICABLE`.

## Audit Scope

Check these consistency classes:

1. **Macro definitions**
   - duplicate `\newcommand`, `\renewcommand`, `\DeclareMathOperator`, or
     theorem environment definitions with conflicting meanings;
   - macros defined but never used;
   - macros used but not defined when they are project-specific.
2. **Symbol table**
   - each newly introduced symbol has a prose definition near first use;
   - the same symbol is not reused for multiple concepts;
   - the same concept is not renamed across sections without an explicit bridge;
   - matrices, vectors, scalars, sets, indices, and dimensions follow one
     convention.
3. **Equation labels and references**
   - every `\label{...}` is unique;
   - every `\eqref{...}`, `\ref{...}`, and `\cref{...}` target exists;
   - equation labels are not stale after section restructuring.
4. **Formula continuity**
   - variables used in a displayed equation were introduced before or directly
     after the equation;
   - assumptions used in formulas are named consistently;
   - dimensions and index ranges do not silently change.
5. **Theorem and appendix restatements**
   - theorem/lemma/proposition/corollary statements repeated in the appendix
     preserve hypotheses, quantifiers, case splits, domains, variables, and
     labels;
   - appendix notation matches the main-body notation or includes an explicit
     notation bridge.
6. **Long-conversation drift**
   - compare current files against `math_commands.tex`, `PAPER_PLAN.md`, and
     `PAPER_GUIDE.md` when present;
   - flag terms or symbols that appear to have changed names across drafting
     sessions.

## Workflow

### Step 1: Collect Paper Sources

Resolve the paper directory and build a deterministic file list:

```bash
PAPER_DIR="${1:-paper}"
rg -n '\\(input|include)\{[^}]+\}|\\label\{|\\(eqref|ref|cref)\{|\\newcommand|\\renewcommand|\\DeclareMathOperator|\\begin\{(equation|align|theorem|lemma|proposition|corollary|definition|assumption)\}' "$PAPER_DIR"
```

Include both legacy and ICDE/Overleaf layouts:

```text
paper/Content/*.tex
paper/sections/*.tex
paper/sec/*.tex
paper/*.tex
paper/math_commands.tex
```

Do not read unrelated experiment logs or prior reviewer reports as evidence for
math consistency. This audit should be based on the manuscript source.

### Step 2: Build Ledgers

Create four ledgers in memory before judging:

- **Macro ledger**: macro name, definition text, file, line, usage count.
- **Label ledger**: label key, kind, defining file/line, referencing file/line.
- **Symbol ledger**: symbol or notation phrase, first definition, later uses,
  inferred type when obvious.
- **Restatement ledger**: theorem-like blocks with labels and any repeated block
  sharing the same label or title.

Use exact snippets for labels and macro definitions. For symbol definitions,
quote only short local excerpts and summarize the issue.

### Step 3: Classify Issues

Classify each issue with:

- `severity`: `CRITICAL`, `MAJOR`, `MINOR`
- `category`: `macro_conflict`, `undefined_macro`, `unused_macro`,
  `symbol_reuse`, `concept_rename`, `missing_definition`,
  `dimension_drift`, `duplicate_label`, `undefined_reference`,
  `stale_label`, `restatement_drift`, `appendix_notation_drift`,
  `equation_context_gap`
- `location`: `file:line`
- `evidence`: short description of the mismatch
- `suggested_fix`: conservative text describing what to align

Severity guidance:

- `CRITICAL`: conflicting theorem/restatement hypotheses, duplicate labels that
  break references, same symbol used for incompatible objects, or formula
  dimensions that contradict each other.
- `MAJOR`: missing symbol definitions, concept renames without bridge text,
  undefined references, appendix notation drift.
- `MINOR`: unused macros, naming style inconsistency, local equation context
  that is understandable but weak.

Do not automatically edit the paper. Low-risk fixes may be suggested, but the
default output is an audit report only.

### Step 4: Emit Reports

Write `MATH_CONSISTENCY_AUDIT.md` and `MATH_CONSISTENCY_AUDIT.json` at the
paper directory root.

Markdown shape:

```markdown
# Math Consistency Audit

**Date**: [UTC ISO-8601]
**Paper**: [paper dir]
**Verdict**: PASS | WARN | FAIL | NOT_APPLICABLE | BLOCKED | ERROR

## Summary
- Files scanned: N
- Macros: N definitions, M conflicts
- Labels: N definitions, M undefined references
- Symbols: N tracked, M consistency issues
- Restatements: N checked, M drift issues

## Issues
| Severity | Category | Location | Finding | Suggested fix |
|---|---|---|---|---|

## Notation Ledger
[compact symbol table for high-value symbols only]
```

JSON shape:

```json
{
  "audit_skill": "paper-math-consistency-audit",
  "verdict": "PASS | WARN | FAIL | NOT_APPLICABLE | BLOCKED | ERROR",
  "reason_code": "no_math_content | all_consistent | notation_drift | critical_conflict | source_unreadable | error",
  "summary": "One-line human-readable verdict summary.",
  "audited_input_hashes": {
    "main.tex": "sha256:...",
    "Content/2.Methodology.tex": "sha256:...",
    "math_commands.tex": "sha256:..."
  },
  "trace_path": ".debuffer_skills/traces/paper-math-consistency-audit/<date>_runNN/",
  "thread_id": null,
  "reviewer_model": null,
  "reviewer_reasoning": null,
  "generated_at": "<UTC ISO-8601>",
  "details": {
    "files_scanned": 0,
    "macro_count": 0,
    "label_count": 0,
    "tracked_symbols": 0,
    "issues": []
  }
}
```

### Verdict Decision Table

| Input state | Verdict | `reason_code` example |
|---|---|---|
| No math macros, equations, labels, or theorem-like blocks | `NOT_APPLICABLE` | `no_math_content` |
| Source files cannot be read | `BLOCKED` | `source_unreadable` |
| No issues found | `PASS` | `all_consistent` |
| Only MINOR/MAJOR notation issues | `WARN` | `notation_drift` |
| Any CRITICAL conflict | `FAIL` | `critical_conflict` |
| Tooling or parsing failed unexpectedly | `ERROR` | `error` |

### Hashing Rules

Hash the exact `.tex` and macro files scanned. Use paths relative to the paper
directory for files inside it, and absolute paths for files outside it. This
matches the submission verifier convention used by the other paper audits.

## Key Rules

- Always emit `MATH_CONSISTENCY_AUDIT.json`; silent skip is forbidden.
- Do not rewrite mathematical content by default.
- Do not treat proof validity as in scope; route proof soundness to
  `/proof-checker`.
- Prefer concrete file/line findings over broad style advice.
- For ICDE/Overleaf layouts, scan `Content/`, `Figure/`, and `IEEE.bib`
  adjacent source structure; figures and bibliography are not primary audit
  inputs but may reveal stale labels or notation in captions.
