---
name: experiment-plan
description: 'Turn a refined research proposal or method idea into a detailed, question- and mechanism-driven experiment roadmap. Use after `research-refine`, or when the user asks for a detailed experiment plan, ablation matrix, evaluation protocol, run order, compute budget, or paper-ready validation that supports the core problem, novelty, simplicity, and any LLM / VLM / Diffusion / RL-based contribution.'
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, WebSearch, WebFetch
---

# Experiment Plan: Question-Driven, Paper-Oriented Validation

## Capability Routing

This is a first-layer entry skill. Keep it loaded as the user-facing route; when a request needs a specialized capability below, resolve the debuffer repo root from `.debuffer_skills/installed-skills-codex.txt` (`repo_root`) when available, read the referenced library `SKILL.md`, then follow that skill. Do not copy the whole library skill into this file.

- `/ablation-planner`: read `../library/idea-method/ablation-planner/SKILL.md`.
- `/run-experiment`: read `../library/experiments/run-experiment/SKILL.md`.
- `/training-check`: read `../library/experiments/training-check/SKILL.md`.
- `/system-profile`: read `../library/experiments/system-profile/SKILL.md`.


Refine and concretize: **$ARGUMENTS**

## Overview

Use this skill after the method is stable enough that the next question becomes: **what exact experiments should we run, in what order, to understand the mechanism and prepare paper evidence?** If the user wants the full chain in one request, run `/research-refine` first and continue here once the method thesis is stable.

The goal is not to generate a giant benchmark wishlist. The goal is to turn a proposal into a **question -> evidence -> run order** roadmap that supports four things:

1. the method actually solves the anchored problem
2. the dominant contribution is real and focused
3. the method is elegant enough that extra complexity is unnecessary
4. any frontier-model-era component is genuinely useful, not decorative

## Project Guide Integration

Read `../shared-references/project-guide-protocol.md` before writing outputs.
Use it to keep experiment planning connected to the project's macro phase
without generating redundant long documents:

- Update `PROJECT_STATUS.md` to the `experiment protocol` phase when the
  experiment story becomes stable enough for implementation planning.
- Keep `refine-logs/EXPERIMENT_PLAN.md` as the operational roadmap. Create or
  refresh `docs/experiments/EXPERIMENT_PROTOCOL.md` only when the plan is ready
  for implementation, AutoDL smoke preparation, or formal-run freezing.
- Before a formal experiment protocol or AutoDL formal-run plan, read
  `docs/project/RESEARCH_BLUEPRINT.md` and
  `docs/project/BLUEPRINT_GATE.md` when present, falling back to legacy root
  files only for old projects. If they are absent and the method is stable
  enough for formal runs, run or request `research-blueprint` first. Do not
  block exploratory experiment planning on a missing blueprint.
- If the idea is still exploratory, update only compact state such as
  `docs/project/PROJECT_BRIEF.md` and `docs/project/NEXT_ACTIONS.md`; do not
  emit `docs/project/PROJECT_GUIDE.md`, `docs/evidence/EVIDENCE_LEDGER.md`, or
  `docs/paper/PAPER_GUIDE.md` unless their gates are reached.
- Also read `../shared-references/autosci-lite-patterns.md`. Before writing a
  formal run plan, scan `idea-stage/IDEA_MEMORY.md` and
  `experiments/NEGATIVE_RESULTS.md`, then add a pilot gate unless equivalent
  smoke evidence already exists or the user explicitly waives it.

## Constants

- **OUTPUT_DIR = `refine-logs/`** — Default destination for experiment planning artifacts.
- **MAX_PRIMARY_FINDINGS = 2** - Prefer one dominant expected finding plus one supporting finding.
- **MAX_CORE_BLOCKS = 5** — Keep the must-run experimental story compact.
- **MAX_BASELINE_FAMILIES = 3** — Prefer a few strong baselines over many weak ones.
- **DEFAULT_SEEDS = 3** — Use 3 seeds when stochastic variance matters and budget allows.

## Workflow

### Phase 0: Load the Proposal Context

Read the most relevant existing files first if they exist:

- `docs/project/RESEARCH_BLUEPRINT.md` (fall back to legacy `RESEARCH_BLUEPRINT.md`)
- `docs/project/BLUEPRINT_GATE.md` (fall back to legacy `BLUEPRINT_GATE.md`)
- `PROJECT_STATUS.md`
- `refine-logs/FINAL_PROPOSAL.md`
- `refine-logs/REVIEW_SUMMARY.md`
- `refine-logs/REFINEMENT_REPORT.md`

Extract:

- **Problem Anchor**
- **Dominant contribution**
- **Optional supporting contribution**
- **Critical reviewer concerns**
- **Data / compute / timeline constraints**
- **Which frontier primitive is central, if any**

If these files do not exist, derive the same information from the user's prompt.

### Phase 1: Define Core Questions and Expected Findings

Before proposing experiments, write down the research questions and hypotheses the experiments must distinguish.

Use this structure:

- **Primary question / expected finding**: the main mechanism-level result the work is trying to establish
- **Supporting finding**: optional, only if it directly strengthens the main paper story
- **Alternative explanation to rule out**: e.g. "the gain only comes from more parameters," "the gain only comes from a larger search space," or "the modern component is just decoration"
- **Minimum convincing evidence**: what would make each finding believable to a strong reviewer?

Do not exceed `MAX_PRIMARY_FINDINGS` unless the paper truly has multiple inseparable findings.

### Phase 2: Build the Experimental Storyline

Design the paper around a compact set of experiment blocks. Default to the following blocks and delete any that are not needed:

1. **Main anchor result** — does the method solve the actual bottleneck?
2. **Novelty isolation** — does the dominant contribution itself matter?
3. **Simplicity / elegance check** — can a bigger or more fragmented version be avoided?
4. **Frontier necessity check** — if an LLM / VLM / Diffusion / RL-era component is central, is it actually the right tool?
5. **Failure analysis or qualitative diagnosis** — what does the method still miss?

For each block, decide whether it belongs in:

- **Main paper** - essential to establish the core findings
- **Appendix** — useful but non-blocking
- **Cut** — interesting, but not worth the paper budget

Prefer one strong baseline family over many weak baselines. If a stronger modern baseline exists, use it instead of padding the list.

### Phase 3: Specify Each Experiment Block

For every kept block, fully specify:

- **Goal / hypothesis tested**
- **Why this block exists**
- **Dataset / split / task**
- **Design**: factors varied, fixed settings, number of seeds, run order
- **Compared systems**: strongest baselines, ablations, and variants only
- **Metrics**: decisive metrics first, secondary metrics second
- **Setup details**: backbone, frozen vs trainable parts, key hyperparameters, training budget, seeds
- **Expected result / decision rule**: what outcome would support, weaken, or falsify the hypothesis?
- **Failure interpretation**: if the result is negative, what does it mean?
- **Table / figure target**: where this result should appear in the paper
- **Reproducibility entrypoint**: config path, suite path, command, output directory

Special rules:

- A **simplicity check** should usually compare the final method against either an overbuilt variant or a tempting extra component that the paper intentionally rejects.
- A **frontier necessity check** should usually compare the chosen modern primitive against the strongest plausible simpler or older alternative.
- If the proposal is intentionally non-frontier, say so explicitly and skip the frontier block instead of forcing one.

### Phase 4: Turn the Plan Into an Execution Order

Build a realistic run order so the user knows what to do first.

Use this milestone structure:

1. **Sanity stage** — data pipeline, metric correctness, one quick overfit or toy split
2. **Baseline stage** — reproduce the strongest baseline(s)
3. **Main method stage** — run the final method on the primary setting
4. **Decision stage** — run the decisive ablations for novelty, simplicity, and frontier necessity
5. **Polish stage** — robustness, qualitative figures, appendix extras

Insert a **Pilot gate** before any formal AutoDL/HPC suite:

- Pilot spec: reduced dataset/subset, baseline included, proposed variant,
  decisive metrics, bounded budget, and pass/fail/inconclusive rules.
- Output path: `experiments/runs/pilot/<slug>/`.
- If GPU time is needed, write an AutoDL-ready command block or suite path and
  wait for user approval or pasted results.
- Pilot pass means "no obvious collapse"; it is not paper evidence.
- Pilot fail or inconclusive must update `experiments/NEGATIVE_RESULTS.md`, and
  idea-level consequences should update `idea-stage/IDEA_MEMORY.md`.

For each milestone, estimate:

- compute cost
- expected turnaround time
- stop / go decision gate
- risk and mitigation

Separate **must-run** from **nice-to-have** experiments.

### Phase 5: Write the Outputs

#### Step 5.1: Write `refine-logs/EXPERIMENT_PLAN.md`

Use this structure:

```markdown
# Experiment Plan

**Problem**: [problem]
**Method Thesis**: [one-sentence thesis]
**Date**: [today]

## Question / Finding Map
| Question or Finding | Why It Matters | Minimum Convincing Evidence | Linked Blocks |
|-------|-----------------|-----------------------------|---------------|
| C1    | ...             | ...                         | B1, B2        |

## Paper Storyline
- Main paper must prove:
- Appendix can support:
- Experiments intentionally cut:

## Experiment Blocks

### Block 1: [Name]
- Goal / hypothesis tested:
- Why this block exists:
- Dataset / split / task:
- Design:
- Compared systems:
- Metrics:
- Setup details:
- Expected result / decision rule:
- Failure interpretation:
- Table / figure target:
- Reproducibility entrypoint:
- Priority: MUST-RUN / NICE-TO-HAVE

### Block 2: [Name]
...

## Run Order and Milestones
| Milestone | Goal | Runs | Decision Gate | Cost | Risk |
|-----------|------|------|---------------|------|------|
| M0        | ...  | ...  | ...           | ...  | ...  |

## Pilot Gate
- Pilot spec:
- Reduced budget:
- Pass/fail/inconclusive rules:
- AutoDL handoff:
- Output path:
- Decision before formal runs:

## Compute and Data Budget
- Total estimated GPU-hours:
- Data preparation needs:
- Human evaluation needs:
- Biggest bottleneck:

## Risks and Mitigations
- [Risk]:
- [Mitigation]:

## Final Checklist
- [ ] Main paper tables are covered
- [ ] Novelty is isolated
- [ ] Simplicity is defended
- [ ] Frontier contribution is justified or explicitly not claimed
- [ ] Nice-to-have runs are separated from must-run runs
```

#### Step 5.2: Write `refine-logs/EXPERIMENT_TRACKER.md`

Use this structure:

```markdown
# Experiment Tracker

| Run ID | Milestone | Purpose | System / Variant | Split | Metrics | Priority | Status | Notes |
|--------|-----------|---------|------------------|-------|---------|----------|--------|-------|
| R001   | M0        | sanity  | ...              | ...   | ...     | MUST     | TODO   | ...   |
```

Keep the tracker compact and execution-oriented.

#### Step 5.3: Refresh `docs/experiments/EXPERIMENT_PROTOCOL.md` When Stable

If the plan is ready for implementation, AutoDL smoke preparation, or formal
run freezing, create or refresh `docs/experiments/EXPERIMENT_PROTOCOL.md` using
the shared schema from `project-guide-protocol.md`. Keep it compact: link to
`refine-logs/EXPERIMENT_PLAN.md`, list the finalized experiment blocks, and
record the reproducibility entrypoints. Freeze it before formal AutoDL/HPC
runs.

If the plan is not stable yet, skip this file and update only
`PROJECT_STATUS.md` plus `docs/project/NEXT_ACTIONS.md`.

#### Step 5.4: Present a Brief Summary to the User

```
Experiment plan ready.

Must-run blocks:
- [Block 1]
- [Block 2]

Highest-risk assumption:
- [risk]

First three runs to launch:
1. [run]
2. [run]
3. [run]

Plan file: refine-logs/EXPERIMENT_PLAN.md
Tracker file: refine-logs/EXPERIMENT_TRACKER.md
```

## Output Protocols

> Follow these shared protocols for all output files:
> - **[Output Versioning Protocol](../shared-references/output-versioning.md)** — write timestamped file first, then copy to fixed name
> - **[Output Manifest Protocol](../shared-references/output-manifest.md)** — log every output to docs/project/OUTPUT_MANIFEST.md
> - **[Output Language Protocol](../shared-references/output-language.md)** — respect the project's language setting

## Key Rules

- **Large file handling**: If the Write tool fails due to file size, immediately retry using Bash (`cat << 'EOF' > file`) to write in chunks. Do NOT ask the user for permission — just do it silently.

- **Every experiment must answer a research question.** If it does not change a reviewer belief, cut it.
- **Prefer a compact paper story.** Design the main table first, then add only the ablations that defend it.
- **Defend simplicity explicitly.** If complexity is a concern, include a deletion study or a stronger-but-bloated variant comparison.
- **Defend frontier choices explicitly.** If a modern primitive is central, prove why it is better than the strongest simpler alternative.
- **Prefer strong baselines over long baseline lists.** A short, credible comparison set is better than a padded one.
- **Separate must-run from nice-to-have.** Do not let appendix ideas delay the core paper evidence.
- **Reuse proposal constraints.** Do not invent unrealistic budgets or data assumptions.
- **Do not fabricate results.** Plan evidence; do not assert evidence.

## Composing with Other Skills

```
/research-refine   -> method and mechanism refinement
/experiment-plan   -> detailed experiment roadmap
/run-experiment    -> execute the runs
/auto-review-loop  -> react to results and iterate on the paper
```
