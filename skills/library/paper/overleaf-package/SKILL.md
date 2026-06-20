---
name: overleaf-package
description: "Package a local LaTeX paper tree into an Overleaf-uploadable zip without using the Overleaf Git bridge. Use when the user wants to move a local paper to Overleaf by manual upload, needs an uploadable archive for collaborators, or wants a pre-upload audit of missing figures, bib files, and local-only build junk."
argument-hint: "[paper-dir-or-main.tex] [--output-dir dist] [--name <archive-name>]"
allowed-tools: Bash(*), Read, Grep, Glob, Edit, Write
---

# Overleaf Package

This skill prepares a local LaTeX paper for manual Overleaf upload.

- It does not use Overleaf API, token, or Git bridge.
- It produces a zip plus concise manifests under `dist/`.
- It warns on missing figures, missing `.bib`, absolute paths, and other upload risks.

Use this when the target workflow is:

1. Local repo remains the source of truth.
2. You want a clean upload snapshot.
3. Someone will upload the zip in the Overleaf web UI.

If the user wants two-way sync with a Premium Overleaf project, use `/overleaf-sync` instead.

## Default Path

- Input default: `paper/`
- Output default: `dist/overleaf_package_<main>_<timestamp>.zip`
- Companion manifests:
  - `dist/<name>.manifest.txt`
  - `dist/<name>.manifest.json`

## What Gets Included

- Main `.tex` plus recursively referenced `\input{}`, `\include{}`, `\subfile{}`
- Referenced `\includegraphics{}`
- Referenced bibliography files from `\bibliography{}` and `\addbibresource{}`
- Local `.sty`, `.cls`, `.bst`, `.bib`

## What Gets Excluded

- Build junk: `.aux`, `.log`, `.out`, `.toc`, `.fls`, `.fdb_latexmk`, `.synctex.gz`, `.blg`, `.bcf`, `.run.xml`
- Working-state directories such as `.git/`, `dist/`, `paper-overleaf/`

## Recommended Flow

1. If the repo has a local compile path, run `/paper-compile` first.
2. Run the packager.
3. Read the warning section in the manifest.
4. If warnings are only acceptable local issues, upload the zip to Overleaf manually.

Packaging can still succeed with warnings. The warning list is the review surface, not an automatic hard block.

## Command

From the skill repo checkout:

```bash
python3 tools/overleaf_package.py paper
python3 tools/overleaf_package.py paper/main.tex --output-dir dist --name overleaf_ready
```

## Agent Behavior

- Prefer packaging from `paper/` unless the user gives another path.
- If a local compile already failed, still allow packaging, but surface that the archive is only a transport artifact and not compile-verified.
- Do not upload to Overleaf automatically.
- Do not create large extra docs. The zip manifest is enough unless the user asks for a fuller handoff note.

## Output Contract

- `dist/<name>.zip`
- `dist/<name>.manifest.txt`
- `dist/<name>.manifest.json`
- Short summary back to the user:
  - archive path
  - file count
  - whether warnings exist

## See Also

- `/paper-compile` for local compile checks before packaging
- `/overleaf-sync` for Premium Git bridge workflow
