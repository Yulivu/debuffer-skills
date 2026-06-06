---
name: overleaf-package
description: "Package a local LaTeX paper tree into an Overleaf-uploadable zip without using the Overleaf Git bridge. Use when the user wants to move a local paper to Overleaf by manual upload, needs an uploadable archive for collaborators, or wants a pre-upload audit of missing figures, bib files, and local-only build junk."
argument-hint: [paper-dir-or-main.tex] [--output-dir dist] [--name <archive-name>]
allowed-tools: Bash(*), Read, Grep, Glob, Edit, Write
---

# Overleaf Package

This skill produces a manual-upload Overleaf package. It is the non-Premium path.

- No token
- No Overleaf API
- No Git bridge
- Just a clean zip plus a concise manifest

If the user wants a live Premium bridge, use `/overleaf-sync`.

## Tool Location

Resolve `$OVERLEAF_PACKAGER` via the Codex-side chain:

```bash
OVERLEAF_PACKAGER=""
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 1
if [ -z "${SKILL_REPO:-}" ] && [ -f .debuffer_skills/installed-skills-codex.txt ]; then
    SKILL_REPO=$(awk -F'\t' '$1=="repo_root"{print $2; exit}' .debuffer_skills/installed-skills-codex.txt 2>/dev/null) || true
fi
[ -f ".agents/skills/overleaf-package/overleaf_package.py" ] && OVERLEAF_PACKAGER=".agents/skills/overleaf-package/overleaf_package.py"
[ -z "$OVERLEAF_PACKAGER" ] && [ -f "tools/overleaf_package.py" ] && OVERLEAF_PACKAGER="tools/overleaf_package.py"
[ -z "$OVERLEAF_PACKAGER" ] && [ -n "${SKILL_REPO:-}" ] && [ -f "$SKILL_REPO/tools/overleaf_package.py" ] && OVERLEAF_PACKAGER="$SKILL_REPO/tools/overleaf_package.py"
[ -z "$OVERLEAF_PACKAGER" ] && [ -f ~/.codex/skills/overleaf-package/overleaf_package.py ] && OVERLEAF_PACKAGER="$HOME/.codex/skills/overleaf-package/overleaf_package.py"
[ -z "$OVERLEAF_PACKAGER" ] && {
  echo "ERROR: overleaf_package.py not resolved at project install, project tools/, \$SKILL_REPO/tools/, or ~/.codex/skills/overleaf-package/." >&2
  exit 1
}
```

## Recommended Flow

1. If `paper/` exists, treat it as the default source.
2. If the project has `/paper-compile`, run it first when useful.
3. Run the packager.
4. Surface warning lines clearly.
5. Stop at artifact production. The user uploads the zip manually in Overleaf.

## Invocation

```bash
python3 "$OVERLEAF_PACKAGER" paper
python3 "$OVERLEAF_PACKAGER" paper/main.tex --output-dir dist --name overleaf_ready
```

## Inclusion Rules

- Include recursively referenced `.tex`
- Include referenced figures
- Include `.bib`, `.bst`, `.sty`, `.cls`
- Exclude build junk and local state

## Output Contract

- `dist/<name>.zip`
- `dist/<name>.manifest.txt`
- `dist/<name>.manifest.json`

The response back to the user should be short:

- archive path
- file count
- warning count
- reminder that this is for manual upload, not sync

## See Also

- `/paper-compile`
- `/overleaf-sync`
