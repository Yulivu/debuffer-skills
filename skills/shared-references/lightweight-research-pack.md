# Lightweight Research Pack

This file defines the default behavior for the customized research skills.
It overrides older autonomous/API/SSH defaults unless the user explicitly asks
for a legacy backend.

## Defaults

- Work locally only for reading, editing, unit tests, lint, tiny CPU/GPU smoke
  checks, and artifact audit. Do not run heavy training or large sweeps locally.
- Route heavy compute to AutoDL/HPC planning. Prepare commands, manifests,
  preflight checks, smoke suites, and runbooks; require user approval before any
  remote smoke or formal run.
- Do not perform fully autonomous SSH execution by default. If SSH is needed,
  write the exact command block and ask the user to run or approve it.
- Use prompt-only external review by default. Write a reviewer prompt under
  `review-prompts/`, ask the user to open a separate conversation with the
  relevant skill enabled, then consume the pasted review.
- Do not call reviewer APIs, MCP tools, subagents, or Oracle-style backends
  unless the user explicitly enables a legacy reviewer backend.
- Prefer compact artifacts: `PROJECT_BRIEF.md`, `NEXT_ACTIONS.md`,
  `findings.md`, `EXPERIMENT_LOG.md`, and concise `*_SUMMARY.md` files.
  Create long reports such as `IDEA_REPORT.md` or `NARRATIVE_REPORT.md` only
  when downstream paper writing needs them or the user asks.
- Compact periodically instead of appending forever: merge stable state into
  `PROJECT_BRIEF.md`, `findings.md`, and `EXPERIMENT_LOG.md`; archive or leave
  old stage logs unchanged rather than generating another large Markdown file.
- Follow `project-guide-protocol.md` for macro project navigation. Maintain
  `PROJECT_STATUS.md` so the agent can always tell which project phase is
  current; generate larger guides such as `PROJECT_GUIDE.md`,
  `EXPERIMENT_PROTOCOL.md`, `EVIDENCE_LEDGER.md`, or `PAPER_GUIDE.md` only at
  stage gates.
- Keep this skill bundle small. Do not add tutorial corpora, rendered HTML
  galleries, demo screenshots, paper PDFs, slide decks, or marketing media to
  the main package. Generated learning material belongs in the user's project,
  not in this skills repo.

## Install Profiles

Installers may expose these lightweight profiles. `full` remains available for
compatibility, but new research projects should usually start smaller:

- `core-research`: repo architecture, project memory, idea/refine/experiment
  planning, AutoDL/HPC handoff, local validation, and basic audits.
- `paper`: paper planning, LaTeX writing/compile, figures, claim/citation
  audits, rebuttal, and resubmission support.
- `review`: prompt-only external review and evidence-audit tools.
- `full`: every mainline/Codex skill plus shared references.

Profiles are installation scopes only. They must not change the behavior of an
individual `SKILL.md` once installed.

## Startup Modes

Classify the project before scaffolding or planning:

- `venue-only`: user has a target venue/journal and broad direction only.
- `reference-paper`: user has one or more papers to imitate, extend, or refute.
- `reference-codebase`: user has a repository to build on.
- `idea-doc`: user has early notes, hypotheses, or an idea document.
- `existing-repo`: user has a partially organized project repository.
- `partial-results`: user already has logs, figures, tables, or claims.

For early modes, start with a brief, assumptions, literature map, and smallest
validation plan. For later modes, first audit the existing artifacts and avoid
rewriting project history.

## Review Prompt Contract

When external review is requested:

1. Gather only the compact context needed for the reviewer.
2. Write `review-prompts/<scope>_review_prompt.md`.
3. Include target venue, artifact paths, claims, evidence, known weaknesses,
   and the exact questions the reviewer should answer.
4. Stop and ask the user to paste the review back from a separate conversation.
5. After pasted review arrives, write concise `review-stage/REVIEW_SUMMARY.md`
   and `NEXT_ACTIONS.md`; implement only approved changes.

Use this minimum prompt shape:

```markdown
# External Review Prompt

Target venue: <AAAI|ICLR|JMLR|TPAMI|other>
Startup mode: <venue-only|reference-paper|reference-codebase|idea-doc|existing-repo|partial-results>
Artifacts to inspect:
- <path>: <why it matters>

Claims under review:
- <claim> -> <evidence path or missing evidence>

Known weaknesses:
- <weakness>

Reviewer tasks:
1. Identify blocking technical, experimental, writing, and reproducibility issues.
2. Separate must-fix items from nice-to-have items.
3. For each must-fix item, propose the smallest valid fix.
4. Give a venue-specific risk assessment and a concise next-action list.
```

Venue-specific risk should be loaded from `venue-profiles.md` when available.

## AutoDL Boundary

AutoDL/HPC work follows the `autodl-hpc` skill:

- Git-based code sync, target-machine deploy keys, and no private-key upload.
- Offline data policy with `data/DATA_MANIFEST.md`.
- Preflight and smoke gates before formal suites.
- Formal runs disabled until dry-run passes and the user approves.
- Raw run outputs return to `experiments/runs/`; curated paper evidence goes
  to `experiments/results/` only after local audit.

## Remote Command Gate

Treat `ssh`, `scp`, `rsync`, `screen`, `tmux`, `nohup`, remote package install,
formal suite launch, and large result download as gated operations. By default:

1. Print the exact command block.
2. State the expected side effects and cost/risk.
3. Ask the user to run it or explicitly approve execution.
4. Record the approved command and output path in `EXPERIMENT_LOG.md` or the
   runbook.

The only local commands that can run without a special gate are read-only
inspection, formatting, unit tests, lint, import checks, config validation, and
tiny smoke tasks that are clearly bounded.

## Repository Hygiene

For this customized skill bundle:

- Keep only the root Chinese `README.md`; do not add secondary README-like
  files.
- Keep `docs/SKILLS_CATALOG.md` compact and generated from the 79 skills.
- Do not re-add `docs/tutorials/`, `community_papers/`, repo-level demo media,
  or generated HTML/PDF slide artifacts.
- If a skill wants to generate long tutorials, slides, or reports, write them to
  the target project after explicit user request and include a compaction plan.
