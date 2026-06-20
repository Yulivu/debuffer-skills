---
name: artifact-package-splitter
description: Build and maintain a clean separation between public artifact packages and internal writing/advisor packages. Use when the user says "artifact package", "paper package", "writing package", "public artifact vs internal package", "生成投稿包", or "生成写作用包".
---

# Artifact Package Splitter

Use this skill when final results exist and the project needs separate public
artifact content and internal paper-writing/advisor content.

## Package Model

Keep these layers distinct:

- raw run outputs: immutable provenance under `experiments/runs/`.
- promoted/normalized results: curated tables, traces, and figures under
  `experiments/results/` or a project-specific promoted directory.
- public artifact package: English, minimal, factual, reproducible.
- internal writing package: explanatory notes, claim boundaries, narrative
  ordering, and provenance for drafting.

## Public Artifact Rules

The public package must be English only and must not include internal writing
language such as:

- "we should write"
- "claim boundary"
- "advisor"
- "draft"
- "thinking"
- "old experiment"

Include only final tables, figures, LaTeX snippets, trace CSVs, and scripts or
metadata needed for reproduction. Exclude obsolete datasets, old exploratory
traces, local paths, and abandoned package versions.

## Internal Writing Package Rules

The internal package may include Chinese explanatory README files, claim
boundaries, what-can/cannot-be-written notes, narrative ordering, and trace
provenance.

It must copy current final artifact data, not old package data. Do not restore
old numeric values or legacy filenames unless the user explicitly requests a
historical comparison.

When a one-off builder is useful, recommend an ignored script under root
`temp/`, for example `temp/build_internal_writing_package.py`, and keep it out
of Git unless the user wants a reusable maintained tool.

## Checks

Run or prepare checks like:

```bash
rg -n "we should write|claim boundary|advisor|draft|thinking|old experiment|TODO|C:\\Users|/root/autodl" <public-package>
find <public-package> -type f | sort
find <internal-package> -type f | sort
du -sh <public-package> <internal-package>
```

Also verify:

- public tables/figures match current promoted results.
- trace provenance points to current final runs.
- public package README is factual, minimal, and reproducibility-focused.
- internal package did not copy from stale artifact roots.

## Guardrails

- Do not mix public artifact files and internal writing notes.
- Do not manually edit generated numeric tables; regenerate from current traces.
- Do not expose private paths or local operational constraints in public text.
- Do not delete old packages unless the user explicitly approves deletion.
