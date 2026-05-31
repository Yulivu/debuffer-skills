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

## AutoDL Boundary

AutoDL/HPC work follows the `autodl-hpc` skill:

- Git-based code sync, target-machine deploy keys, and no private-key upload.
- Offline data policy with `data/DATA_MANIFEST.md`.
- Preflight and smoke gates before formal suites.
- Formal runs disabled until dry-run passes and the user approves.
- Raw run outputs return to `experiments/runs/`; curated paper evidence goes
  to `experiments/results/` only after local audit.
