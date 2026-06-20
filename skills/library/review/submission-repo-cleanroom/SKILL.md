---
name: submission-repo-cleanroom
description: Clean a research repository before public release or anonymous artifact submission without destroying useful local backups unless explicitly instructed. Use when the user says "clean repo for release", "anonymous artifact cleanup", "投稿前清理repo", "公开代码库前检查", or "remove old experiments".
---

# Submission Repo Cleanroom

Use this skill before public release, anonymous artifact submission, or camera
ready artifact packaging.

The goal is a reproducible public workflow, not a lab notebook dump.

## Workflow

1. Inspect before changing anything:
   - `git status --short`
   - `git ls-files`
   - `git ls-files --others --exclude-standard`
   - `rg --files`
2. Classify files as:
   - `public`: required for reproducibility or final artifact.
   - `ignored-local`: local caches, data, logs, temp scripts, generated previews.
   - `archive-local`: useful backups or history, not public release content.
   - `delete`: generated junk, only after explicit user approval.
3. Audit for:
   - old experiments and old package roots.
   - local backups and notebook checkpoints.
   - smoke outputs and failed run outputs.
   - personal notes, draft notes, advisor notes.
   - stale datasets and non-final configs.
   - internal README text.
   - non-anonymous paths/names.
   - accidental large files.
4. Update `.gitignore` for local-only outputs and generated artifacts.
5. Clean README language so it is academic, reproducibility-focused, and
   concise.
6. Remove stale references to old data, old experiment ids, or abandoned claims.
7. Verify the repo contains only the intended final reproducible workflow.
8. Run final grep/anonymity scans.

## Scan Examples

Use project-specific variants of:

```bash
rg -n "old|backup|TODO|draft|advisor|writing|local|absolute path|C:\\Users|/root/autodl"
rg -n "experiments1|old_package|paper_package_smoke|failed|tmp|checkpoint"
git ls-files | sort
git ls-files --others --exclude-standard | sort
find . -type f -size +50M
```

Also check README and scripts for:

- stale dataset names.
- old output paths.
- private machine paths.
- regional/network constraints. Public text should say generic network
  constraints, not private operational details.

## Guardrails

- Never delete backups without explicit user approval.
- Never revert user changes automatically.
- Never expose private local paths or regional/network constraints in public
  release text.
- Do not move large raw data into Git.
- If anonymity is required, do not leave personal names, usernames, local paths,
  acknowledgments, or non-anonymous package metadata.
