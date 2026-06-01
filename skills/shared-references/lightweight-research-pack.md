# Lightweight Research Pack

This file defines the default behavior for the customized research skills.

## Defaults

- Local work covers reading, editing, unit tests, lint, tiny CPU/GPU smoke
  checks, config validation, and artifact audit.
- Heavy compute is prepared through AutoDL/HPC planning: commands, manifests,
  preflight checks, smoke suites, runbooks, result transfer, and formal-run
  approval.
- Remote operations use a visible gate: exact command block, expected side
  effects, cost/risk note, and user approval.
- External review uses prompt-only handoff by default. The skill writes a
  reviewer prompt under `review-prompts/`, the user runs a separate review
  conversation, and the current project consumes the pasted review.
- Compact artifacts are preferred, but root Markdown stays sparse. Keep
  `PROJECT_STATUS.md` in the root; write other project memory under `docs/`,
  for example `docs/project/PROJECT_BRIEF.md`,
  `docs/project/NEXT_ACTIONS.md`, `docs/evidence/findings.md`,
  `docs/experiments/EXPERIMENT_LOG.md`, and concise category-local
  `*_SUMMARY.md` files.
- AutoSci-lite patterns are available for idea paths, failure memory, pilot
  gates, and macro state. Read `autosci-lite-patterns.md` when a project starts
  from a broad direction, has failed ideas/results, or is preparing formal
  AutoDL experiments.
- Stage-gate guides such as `RESEARCH_BLUEPRINT.md`, `BLUEPRINT_GATE.md`,
  `PROJECT_GUIDE.md`, `EXPERIMENT_PROTOCOL.md`, `EVIDENCE_LEDGER.md`, and
  `PAPER_GUIDE.md` appear at handoff points. Use `RESEARCH_BLUEPRINT.md` for
  the detailed pre-experiment or pre-paper design; keep routine updates in
  compact memory files.
- Generated tutorials, rendered HTML, screenshots, PDFs, slide decks, and
  media assets live in the target project when explicitly requested.

## Install Profiles

- `core-research`: repo architecture, project memory, idea/refine/experiment
  planning, AutoDL/HPC handoff, local validation, and basic audits.
- `paper`: paper planning, LaTeX writing/compile, figures, claim/citation
  audits, rebuttal, and resubmission support.
- `review`: prompt-only external review and evidence-audit tools.
- `full`: every mainline/Codex skill plus shared references.

Profiles are installation scopes. Each installed `SKILL.md` keeps the same
behavior regardless of profile.

## Startup Modes

Classify the project before scaffolding or planning:

- `venue-only`: user has a target venue/journal and broad direction.
- `reference-paper`: user has one or more papers to imitate, extend, or refute.
- `reference-codebase`: user has a repository to build on.
- `idea-doc`: user has early notes, hypotheses, or an idea document.
- `existing-repo`: user has a partially organized project repository.
- `partial-results`: user already has logs, figures, tables, or claims.

Early modes start with a brief, assumptions, literature map, and smallest
validation plan. Later modes start with artifact inventory and evidence audit.

## Idea And Failure Memory

Use `autosci-lite-patterns.md` for the A-E idea paths and lightweight negative
memory. Keep `idea-stage/IDEA_MEMORY.md` and
`experiments/NEGATIVE_RESULTS.md` compact and append-only. Before generating
new ideas or experiment plans, scan them as a banlist so the project does not
repeat failed directions.

## Review Prompt Contract

When external review is requested:

1. Gather the compact context needed for the reviewer.
2. Write `review-prompts/<scope>_review_prompt.md`.
3. Include target venue, artifact paths, claims, evidence, known weaknesses,
   and exact reviewer questions.
4. Ask the user to paste the review back from a separate conversation.
5. Write `review-stage/REVIEW_SUMMARY.md` and `NEXT_ACTIONS.md`; implement
   approved changes.

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

- Git-based code sync and target-machine deploy-key bootstrap.
- Offline data policy with `data/DATA_MANIFEST.md`.
- Preflight and smoke gates before formal suites.
- Pilot gate before formal suites unless equivalent smoke evidence already
  exists. Pilot output is engineering evidence, not paper evidence.
- Formal-run approval after dry-run and smoke output are accepted.
- Raw run outputs return to `experiments/runs/`; curated paper evidence goes
  to `experiments/results/` after local audit.

## Remote Command Gate

Treat `ssh`, `scp`, `rsync`, `screen`, `tmux`, `nohup`, remote package install,
formal suite launch, and large result download as gated operations. The gate
contains:

1. Exact command block.
2. Expected side effects and cost/risk.
3. User approval point.
4. Output path recorded in `EXPERIMENT_LOG.md` or the runbook.

Local commands covered by the lightweight default are read-only inspection,
formatting, unit tests, lint, import checks, config validation, and tiny smoke
tasks with bounded runtime.

## Repository Hygiene

For this customized skill bundle:

- Root Chinese `README.md` and `docs/SKILLS_CATALOG.md` are the public docs.
- `docs/SKILLS_CATALOG.md` stays compact and reflects the active skill count.
- Long generated tutorials, demo media, PDFs, and rendered artifacts belong to
  target projects with explicit user request.
- Long project reports include a compaction plan and a stage-gate refresh path.
  `docs/project/RESEARCH_BLUEPRINT.md` is patched at major gates, not
  regenerated on every session.
- Ordinary research repos should keep only `README.md`, `PROJECT_STATUS.md`,
  and tool-managed `AGENTS.md` / `CLAUDE.md` in the root. Put all other
  Markdown under categorized `docs/` folders.
