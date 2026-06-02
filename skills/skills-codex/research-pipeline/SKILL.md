---
name: research-pipeline
description: "Lightweight AutoDL-first research pipeline: idea discovery → blueprint → experiment planning/AutoDL gates → prompt-only review/audit → optional evidence-gated paper planning. Adapts to venue-only, reference-paper/codebase, idea-doc, existing-repo, or partial-results starts; avoids heavy local compute, defaults to concise artifacts, and prepares AutoDL/HPC gated runs. Use when user says \"全流程\", \"full pipeline\", \"从找idea到投稿\", \"end-to-end research\", or wants a complete but user-gated research lifecycle. Manuscript drafting is allowed only after formal runs and evidence audit pass."
---

# Full Research Pipeline: Idea → Experiments → Submission

End-to-end autonomous research workflow for: **$ARGUMENTS**

## Customized Pack Defaults

Read `../shared-references/lightweight-research-pack.md` before running the
pipeline. In this customized pack, the following defaults override older
autonomous settings below unless the user explicitly asks for legacy automation:

- **STARTUP_MODE = auto**: classify the project as `venue-only`,
  `reference-paper`, `reference-codebase`, `idea-doc`, `existing-repo`, or
  `partial-results` before choosing the first stage.
- **AUTO_PROCEED = false**, **HUMAN_CHECKPOINT = true**, **COMPACT = true**,
  **RENDER_HTML = false**.
- **REVIEW_MODE = prompt-only**: generate `review-prompts/*_review_prompt.md`
  and wait for pasted feedback from a separate review conversation. Do not call
  reviewer agents unless the user explicitly opts into legacy review.
- **CODE_REVIEW = prompt-only**: for implementation review, write a code-review
  prompt file instead of calling a reviewer agent directly.
- **LOCAL_HEAVY_COMPUTE = false**, **DEPLOY_TARGET = autodl**: local work is
  limited to edits, lint/tests, dry runs, and tiny smoke checks. Heavy training
  or sweeps must be prepared through `/autodl-hpc` with approval gates.
- **AUTO_WRITE = false** remains the default and cannot override the evidence
  gate. Produce compact
  `docs/project/PROJECT_BRIEF.md`, `docs/evidence/findings.md`,
  `docs/experiments/EXPERIMENT_LOG.md`, and
  `docs/project/NEXT_ACTIONS.md`; create `docs/paper/NARRATIVE_REPORT.md` only
  after formal runs and evidence audit pass, or when the user explicitly asks
  for a clearly labeled pre-paper gap artifact.
- **BLUEPRINT_GATE = required at handoffs**: before formal experiment planning,
  AutoDL formal runs, or paper planning, create or refresh
  `docs/project/RESEARCH_BLUEPRINT.md` and
  `docs/project/BLUEPRINT_GATE.md` via `/research-blueprint`.
  Keep routine updates compact.

For venue-specific review and writing, read
`../shared-references/venue-profiles.md` and apply the target venue profile
(ICLR, AAAI, JMLR, TPAMI, NeurIPS/ICML, or IEEE).

Read `../shared-references/project-guide-protocol.md` when the user wants a
project-wide guide or when crossing a stage gate. Keep `PROJECT_STATUS.md`
updated after each accepted stage. Generate `docs/project/PROJECT_GUIDE.md`,
`docs/project/RESEARCH_BLUEPRINT.md`, `docs/project/BLUEPRINT_GATE.md`,
`docs/experiments/EXPERIMENT_PROTOCOL.md`,
`docs/evidence/EVIDENCE_LEDGER.md`, or `docs/paper/PAPER_GUIDE.md` only when
their gate conditions are met; otherwise update compact memory files.

## Constants

- **AUTO_PROCEED = false** — Wait for explicit user confirmation before leaving idea selection or any expensive gate.
- **ARXIV_DOWNLOAD = false** — When `true`, `/research-lit` downloads the top relevant arXiv PDFs during literature survey. When `false` (default), only fetches metadata via arXiv API. Passed through to `/idea-discovery` → `/research-lit`.
- **HUMAN_CHECKPOINT = true** — Pause review loops after each round so the user can inspect feedback before fixes or new experiments.
- **REVIEWER_DIFFICULTY = medium** — How adversarial the reviewer is. `medium` (default): standard MCP review. `hard`: adds **Reviewer Memory** + **Debate Protocol**. `nightmare`: GPT reads repo directly via `codex exec` + memory + debate. Passed through to `/auto-review-loop`.
- **CODE_REVIEW = true** — GPT-5.4 xhigh reviews experiment code before deployment. Catches logic bugs before wasting GPU hours. Set `false` to skip. Passed through to `/experiment-bridge`.
- **BASE_REPO = false** — GitHub repo URL to use as base codebase. When set, `/experiment-bridge` clones the repo first and implements experiments on top of it. When `false` (default), writes code from scratch or reuses existing project files. Passed through to `/experiment-bridge`.
- **COMPACT = true** — Generate compact summary files for short-context models and session recovery. Passed through to `/idea-discovery` and `/experiment-bridge`.
- **AUTO_WRITE = false** — When `true`, it may request the paper-writing workflow only after formal runs, evidence audit, and paper-plan gates pass. When `false` (default), stop at the next allowed gate and do not present manuscript commands.
- **VENUE = ICLR** — Target venue for paper writing (Stage 5). Only used when `AUTO_WRITE=true`. Options: `ICLR`, `NeurIPS`, `ICML`, `CVPR`, `ACL`, `AAAI`, `ACM`, `IEEE_CONF`, `IEEE_JOURNAL`.
- **RENDER_HTML = false** — Render `docs/paper/NARRATIVE_REPORT.md` only when that evidence-audited artifact is actually generated and the user asks or opts in.

> 💡 Override via argument, e.g., `/research-pipeline "topic" — AUTO_PROCEED: false, human checkpoint: true, difficulty: nightmare, code review: false, base repo: https://github.com/org/project, auto_write: true, venue: NeurIPS`.

## Overview

This skill chains the research lifecycle into a gated pipeline:

```
/idea-discovery → /research-blueprint → /experiment-bridge/autodl-hpc → /experiment-audit → /paper-plan → /paper-writing (gated)
├── Workflow 1 ──┤├── Stage-gate design ──┤├── Workflow 1.5 ──┤├── Workflow 2 ───┤├── Workflow 3 ──┤
```

It orchestrates the major research workflows plus blueprint and evidence gates.
Paper writing is optional and controlled by both `AUTO_WRITE` and the
manuscript entry gate; `AUTO_WRITE=true` is ignored when formal evidence is
missing.

## Pipeline

### Stage 1: Idea Discovery (Workflow 1)

If `docs/project/RESEARCH_BRIEF.md` exists, load it as detailed context (replaces one-line prompt). Fall back to legacy root `RESEARCH_BRIEF.md` only for older projects. See `templates/RESEARCH_BRIEF_TEMPLATE.md`.

Invoke the idea discovery pipeline:

```
/idea-discovery "$ARGUMENTS"
```

This internally runs: `/research-lit` → `/idea-creator` → `/novelty-check` → `/research-review`

**Output:** `idea-stage/IDEA_REPORT.md` with ranked, validated, pilot-tested ideas.

**Review Tracing** follows the downstream review skills. Stage 1 and Stage 3 preserve reviewer prompts/responses through their own trace protocols so the final handoff can be audited.

**🚦 Gate 1 — Human Checkpoint:**

After `idea-stage/IDEA_REPORT.md` is generated, **pause and present the top ideas to the user**:

```
📋 Idea Discovery complete. Top ideas:

1. [Idea 1 title] — Pilot: POSITIVE (+X%), Novelty: CONFIRMED
2. [Idea 2 title] — Pilot: WEAK POSITIVE (+Y%), Novelty: CONFIRMED
3. [Idea 3 title] — Pilot: NEGATIVE, eliminated

Recommended: Idea 1. Shall I proceed with implementation?
```

**If AUTO_PROCEED=false:** Wait for user confirmation before continuing. The user may:
- **Approve the idea** → proceed to Stage 2. `/experiment-bridge` reads `refine-logs/EXPERIMENT_PLAN.md` already generated by `/idea-discovery`.
- **Request changes** (e.g., "combine Idea 1 and 3", "focus more on X") → update the idea prompt with user feedback, re-run `/idea-discovery` with refined constraints, and present again.
- **Reject all ideas** → collect feedback on what's missing, re-run Stage 1 with adjusted research direction. Repeat until the user commits to an idea.
- **Stop here** → save current state to `idea-stage/IDEA_REPORT.md` for future reference.

**If AUTO_PROCEED=true:** Present the top ideas, wait 10 seconds for user input. If no response, auto-select the #1 ranked idea (highest pilot signal + novelty confirmed) and proceed to Stage 2. Log: `"AUTO_PROCEED: selected Idea 1 — [title]"`.

> ⚠️ **This gate waits for user confirmation when AUTO_PROCEED=false.** When `true`, it auto-proceeds after presenting results. The rest of the pipeline (Stages 2-3) is expensive (GPU time + multiple review rounds), so set `AUTO_PROCEED=false` if you want a final review checkpoint before committing GPU resources.

### Stage 1.5: Research Blueprint Gate

When the user commits to an idea or stable method, run `/research-blueprint`
before implementation or formal experiment planning. It writes
`docs/project/RESEARCH_BLUEPRINT.md` with the sequential overall progress table and
`docs/project/BLUEPRINT_GATE.md` with PASS / CONDITIONAL / BLOCKED. Continue only to the
allowed next step recorded in the gate. If the idea is still exploratory, keep
using `docs/project/PROJECT_BRIEF.md`, `PROJECT_STATUS.md`, and
`docs/project/NEXT_ACTIONS.md` instead of
creating the large blueprint.

### Stage 2: Experiment Bridge (Workflow 1.5)

Once the user confirms which idea to pursue, delegate implementation and deployment to `/experiment-bridge`:

```
/experiment-bridge "$CHOSEN_IDEA_TITLE" — code review: $CODE_REVIEW, base repo: $BASE_REPO, compact: $COMPACT
```

> 💡 **Queue routing is automatic**: `/experiment-bridge` Phase 4 routes each milestone by job count — ≤5 jobs → `/run-experiment`, ≥10 jobs or teacher→student phase dependencies → `/experiment-queue` (with OOM retry, wave gating, crash-safe state). No manual override is needed.

**What this does (fully autonomous):**
1. Parses `refine-logs/EXPERIMENT_PLAN.md` — extracts milestones, run order, compute budget
2. Implements experiment code — extends pilot to full scale, follows existing codebase conventions
3. **Cross-model code review** — GPT-5.4 xhigh reviews the implementation for logic bugs, incorrect metrics, and ground-truth misuse before any GPU time is spent
4. **Sanity check** — runs the smallest experiment first to verify the environment; auto-debugs failures (up to 3 attempts, with `/codex:rescue` fallback)
5. Deploys full experiments — auto-routes by job count (≤5 → `/run-experiment`, ≥10 → `/experiment-queue` with OOM retry, wave gating, crash-safe state)
6. Collects initial results — parses outputs, updates `refine-logs/EXPERIMENT_TRACKER.md`, runs `/training-check` if W&B is configured
7. Auto-plans ablations via `/ablation-planner` if main results are positive

**Output:**
- `refine-logs/EXPERIMENT_RESULTS.md` — structured results by milestone
- `refine-logs/EXPERIMENT_TRACKER.md` — updated run-by-run status
- `docs/experiments/EXPERIMENT_LOG.md` (when `COMPACT=true`) — session-recovery-friendly log

**Monitor progress** (while experiments run):

```
/monitor-experiment [server]
```

Wait for `/experiment-bridge` to complete and report its handoff summary before proceeding.

### Stage 3: Auto Review Loop (Workflow 2)

Once initial results are in, start the autonomous improvement loop:

```
/auto-review-loop "$ARGUMENTS — [chosen idea title], difficulty: $REVIEWER_DIFFICULTY"
```

**What this does (up to 4 rounds):**
1. GPT-5.4 xhigh reviews the work (score, weaknesses, minimum fixes)
2. Claude Code implements fixes (code changes, new experiments, reframing)
3. Deploy fixes, collect new results
4. Re-review → repeat until score ≥ 6/10 or 4 rounds reached

**Output:** `review-stage/AUTO_REVIEW.md` with full review history and final assessment.

### Stage 4: Evidence Summary & Paper-Readiness Gate

After the auto-review loop completes, run an evidence-readiness gate before any
paper handoff.

**Step 1:** Write or update the compact research status:
- `PROJECT_STATUS.md`
- `docs/evidence/findings.md`
- `docs/experiments/EXPERIMENT_LOG.md`
- `docs/project/NEXT_ACTIONS.md`

**Step 2:** Check the manuscript-entry prerequisites:
- formal baseline/main/required ablation runs exist for paper-level claims;
- raw evidence names run folders, metrics, configs/resolved configs, seeds,
  logs/metadata, and result summaries;
- `docs/evidence/EVIDENCE_LEDGER.md`, `CLAIMS_FROM_RESULTS.md`, or an
  equivalent audit maps claims to raw evidence and unresolved gaps;
- `docs/project/BLUEPRINT_GATE.md` does not block paper planning.

If any prerequisite fails, stop in the experiment/audit phase. Do not generate
`docs/paper/NARRATIVE_REPORT.md`, do not render HTML, and do not present
`/paper-writing`. The next step should be `experiment-plan`, `autodl-hpc`,
`experiment-audit`, evidence-ledger completion, or stop.

If the gate passes, generate `docs/paper/NARRATIVE_REPORT.md` as a compact
evidence-audited handoff for `paper-plan`, not as a manuscript draft.

The narrative report must contain:
- Problem statement and core claim
- Method summary
- Formal quantitative results with raw evidence for each claim
- Figure/table inventory (which exist, which need manual creation)
- Limitations and remaining follow-up items

**Output:** compact status files, and `docs/paper/NARRATIVE_REPORT.md` only
when the evidence gate passes.

```markdown
# Research Pipeline Report

**Direction**: $ARGUMENTS
**Chosen Idea**: [title]
**Date**: [start] → [end]
**Pipeline**: idea-discovery → experiment-bridge → auto-review-loop

## Journey Summary
- Ideas generated: X → filtered to Y → piloted Z → chose 1
- Implementation: [brief description of what was built]
- Experiments: [number of GPU experiments, total compute time]
- Review rounds: N/4, final score: X/10

## Paper-Readiness Gate
- Formal runs complete: [yes/no + evidence path]
- Evidence audit complete: [yes/no + artifact path]
- Allowed next step: [experiment-plan/autodl-hpc/experiment-audit/paper-plan/stop]
- Narrative report: [generated only if gate passed]

## Remaining TODOs (if any)
- [items flagged by reviewer that weren't addressed]
```

### Stage 5: Paper Planning / Writing (Gated Optional)

This corresponds to **Stage 6: Paper Writing** in the macro lifecycle, but that
stage remains closed until formal runs, evidence audit, and `paper-plan` gates
pass.

If Stage 4 does not pass, skip this stage entirely.

If Stage 4 passes and `AUTO_WRITE=false` (default), stop after presenting the
paper-planning command, not a manuscript command:

```
Evidence gate passed. Next allowed step:
/paper-plan "docs/paper/NARRATIVE_REPORT.md" --venue [VENUE]
```

If `AUTO_WRITE=true`, first run or request `/paper-plan`. Invoke
`/paper-writing` only if the resulting `docs/paper/PAPER_PLAN.md` says the
manuscript entry gate passed and the user explicitly confirms. Never proceed
from Stage 4 directly to LaTeX drafting.

Checks before any manuscript drafting:
- If `VENUE` is missing, stop and ask. Do not silently use a default venue.
- If formal evidence or the paper plan gate is missing, stop and write
  `docs/project/NEXT_ACTIONS.md`.
- If manual figures are required, pause and list them. Wait for user approval.

## Render HTML view (opt-in, only after evidence gate passes)

Only after Stage 4 finalizes an evidence-audited
`docs/paper/NARRATIVE_REPORT.md`, optionally invoke `/render-html` on the
narrative report:

```
/render-html "docs/paper/NARRATIVE_REPORT.md" --no-review
```

`--no-review` is intentional: this is an internal handoff doc, not a
reviewer-facing final artifact. Output: `NARRATIVE_REPORT.html` next to the MD,
with embedded source SHA256.

**Non-blocking**: if `/render-html` fails (helper missing, file write error,
etc.), log the failure and continue. The HTML view is a convenience artifact,
not a paper-readiness prerequisite.

Skip this step if `RENDER_HTML = false`.

## Output Protocols

> Follow these shared protocols for all output files:
> - **[Output Versioning Protocol](../shared-references/output-versioning.md)** — write timestamped file first, then copy to fixed name
> - **[Output Manifest Protocol](../shared-references/output-manifest.md)** — log every output to docs/project/OUTPUT_MANIFEST.md
> - **[Output Language Protocol](../shared-references/output-language.md)** — respect the project's language setting

## Key Rules

- **Large file handling**: If the Write tool fails due to file size, immediately retry using Bash (`cat << 'EOF' > file`) to write in chunks. Do NOT ask the user for permission — just do it silently.

- **Human checkpoint after Stage 1 is controlled by AUTO_PROCEED.** When `false`, do not proceed without user confirmation. When `true`, auto-select the top idea after presenting results.
- **Stages 2-3 can run autonomously** once the user confirms the idea. This is the "sleep and wake up to results" part.
- **If Stage 3 ends at round 4 without positive assessment**, stop and report remaining issues. Do not loop forever.
- **Budget awareness**: Track total GPU-hours across the pipeline. Flag if approaching user-defined limits.
- **Documentation**: Every stage updates its own output file. The full history should be self-contained.
- **Fail gracefully**: If any stage fails (no good ideas, experiments crash, review loop stuck), report clearly and suggest alternatives rather than forcing forward.

## Typical Timeline

| Stage | Duration | Can sleep? |
|-------|----------|------------|
| 1. Idea Discovery | 30-60 min | Yes if AUTO_PROCEED=true |
| 2. Experiment Bridge | 30-120 min (implement + review + deploy + collect) | Yes ✅ |
| 3. Auto Review | 1-4 hours (depends on experiments) | Yes ✅ |

**Sweet spot**: Run Stage 1 in the evening, launch Stage 2-3 before bed, wake up to a reviewed paper.
