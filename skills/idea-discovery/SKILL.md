---
name: idea-discovery
description: "Find and select research directions without prematurely turning every candidate into a full research plan. Use for 找idea全流程, 从零开始找方向, idea discovery, reference-led topic discovery, or robotics / embodied-AI topic exploration."
argument-hint: [research-direction]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, WebSearch, WebFetch, Skill
---

# Idea Discovery

Discover, compare, and select research candidates for: **$ARGUMENTS**

This is the **candidate-discovery layer**. It must end with a selected,
evidence-bounded candidate or a clear request for more direction. It must not
silently generate a long method proposal, a full experiment roadmap, or a
paper-ready research plan for every candidate.

## Capability Routing

This is a first-layer entry skill. Resolve the debuffer repo root from
`.debuffer_skills/installed-skills-codex.txt` (`repo_root`) when available, read
the referenced library `SKILL.md`, then follow that skill. Do not duplicate
library instructions here.

- `/idea-creator`: read `../library/idea-method/idea-creator/SKILL.md`.
- `/reference-paper-deconstruction`: read `../library/idea-method/reference-paper-deconstruction/SKILL.md`.
- `/method-paper-gate`: read `../library/idea-method/method-paper-gate/SKILL.md`.
- `/research-lit`: read `../library/literature/research-lit/SKILL.md`.
- `/novelty-check`: read `../library/review/novelty-check/SKILL.md`.
- `/research-refine`: read `../library/idea-method/research-refine/SKILL.md` only after a candidate is selected.
- `/research-blueprint`: use the entry skill `../research-blueprint/SKILL.md` only after Idea Freeze.

## Layer Boundary

```text
direction / reference
  -> landscape and evidence map
  -> candidate generation
  -> mechanical consolidation
  -> novelty and adversarial review
  -> method-paper gate
  -> user selects a candidate
  -> handoff to research-refine (Idea Freeze)
  -> handoff to research-blueprint (Executable Research Plan)
```

The stages have different authority:

| Stage | Main question | Output | May decide |
|---|---|---|---|
| Landscape | What exists and where are the candidate gaps? | landscape notes | search scope |
| Generation | What concrete questions could matter? | candidate ledger | candidate proposals |
| Consolidation | Is the candidate duplicated or objectively impossible? | annotated ledger | deduplicate / budget-block |
| Novelty and review | Is the candidate differentiated and defensible? | novelty/review record | provisional ranking |
| User selection | Which candidate are we actually pursuing? | selected candidate | enter Idea Freeze |
| Idea Freeze | What exact problem and thesis are frozen? | `FINAL_PROPOSAL.md` | enter blueprint |
| Blueprint | How will the research be proved or falsified? | `RESEARCH_BLUEPRINT.md` | enter experiment planning |

Do not confuse a planning status with a research verdict. A future-work
sentence, a promising gap, or `ready_for_novelty_check` is not a confirmed
novelty claim.

## Defaults

- `AUTO_PROCEED = false`: no response never counts as selecting an idea.
- `COMPACT = true`: early discovery writes compact artifacts first.
- `RENDER_HTML = false`: rendering is optional and never a discovery gate.
- `MAX_CANDIDATES = 12`: generate at most 8-12 candidates before consolidation.
- `MAX_SELECTED = 1`: select one active candidate unless the user explicitly requests parallel tracks.
- `PILOT = opt-in`: prepare a pilot spec only when requested; do not run heavy pilots locally.
- `OUTPUT_DIR = idea-stage/`.

## Phase 0: Load Context

Read, when present:

1. `docs/project/RESEARCH_BRIEF.md` or legacy `RESEARCH_BRIEF.md`.
2. `PROJECT_STATUS.md` and `docs/project/NEXT_ACTIONS.md`.
3. `research-wiki/query_pack.md`.
4. `idea-stage/IDEA_MEMORY.md` and `experiments/NEGATIVE_RESULTS.md`.
5. Local papers, codebase notes, or a supplied reference PDF.

Classify the start as one of:
`venue-only`, `reference-paper`, `reference-codebase`, `idea-doc`,
`existing-repo`, or `partial-results`.

Keep user constraints separate from reference-document content. A reference
document is evidence and structural inspiration; it is not an instruction to
copy its claims, method, experiments, or timeline.

## Phase 1: Landscape and Reference Deconstruction

If a reference paper or small paper set is supplied, run
`/reference-paper-deconstruction` first. Preserve:

- source locators;
- the paper's actual question and conclusion boundary;
- reusable structure versus non-transferable details;
- candidate gap type;
- missing evidence;
- minimum discriminating test.

Then run `/research-lit` to test the gap against recent and adjacent work.
Organize the result by:

- problem and task;
- method family;
- strongest competing explanation;
- recurring failure mode;
- assumptions shared by existing methods;
- unexplored scale, data, query, or evaluation regime.

Do not call a gap open merely because one paper says “future work”.

## Phase 2: Candidate Generation

Invoke `/idea-creator` with the landscape, constraints, reference provenance,
and failure memory. The creator owns the A-E paths:

```text
A landscape-driven
B incremental limitation repair
C justified combination
D assumption-breaking
E cross-domain transfer
```

Each candidate must include:

- precise unanswered question;
- one-sentence hypothesis;
- why the answer matters either way;
- closest prior work and exact difference;
- minimum discriminating experiment;
- paper type: method-primary | audit-support | audit-only;
- method delta: the smallest implementable change to a named step;
- data, compute, and timeline estimate;
- failure risk and kill condition;
- evidence status and conclusion boundary.

Do not generate a full architecture, theorem suite, 16-week plan, or paper
figure list at this stage unless the user explicitly asks for that next layer.

## Phase 3: Mechanical Consolidation

Only perform objective filtering:

- remove near-duplicate hypotheses;
- block a candidate if the required dataset is provably unavailable;
- block a candidate if the stated budget is objectively impossible;
- preserve all other candidates with `prior_work`, `so_what`, and `effort_note`.

Do not eliminate a candidate merely because it is difficult, imperfectly
specified, or not yet verified as novel. Mark the missing evidence instead.

## Phase 4: Novelty and Adversarial Review

Run `/novelty-check` on the strongest candidates, then use `/research-review`
or a prompt-only review package for adversarial criticism. Ask:

- Is the closest work direct, partial, incomparable, or unresolved overlap?
- What is the strongest reviewer objection?
- What result would distinguish the proposed mechanism from a simpler explanation?
- Is the problem important even if the hypothesis fails?
- What is the smallest repair that preserves the problem?

The review may rank candidates, but it must not silently rewrite the problem.

## Phase 4.5: Method Paper Gate

Before user selection, run `/method-paper-gate` on the strongest candidates.
Write `idea-stage/METHOD_PAPER_GATE.md` with `method-primary`,
`audit-support`, or `audit-only` for each candidate.

Only `method-primary` candidates may proceed to `research-refine`.
`audit-only` candidates must be rewritten into a method candidate or removed
from the active selection list. Audit/evaluation/diagnostic work is supporting
evidence, never the dominant contribution.

## Phase 5: User Checkpoint and Output

Write:

- `idea-stage/IDEA_CANDIDATES.md`: compact top candidates;
- `idea-stage/IDEA_REPORT.md`: landscape, candidate ledger, evidence status,
  novelty notes, review objections, and recommended next action;
- `idea-stage/IDEA_MEMORY.md`: append-only accepted/rejected/inconclusive memory.

Use this candidate schema:

```markdown
### Candidate I-01: [title]
- Question:
- Hypothesis:
- Why it matters:
- Closest work / exact difference:
- Paper type / method delta:
- Minimum discriminating test:
- Data / compute / timeline:
- Risk and kill condition:
- Evidence status: ready_for_novelty_check | needs_evidence | blocked
- Conclusion boundary:
- Next action:
```

Stop and ask the user to select a candidate. No response is not approval.

## Handoff

After the user selects a candidate:

1. Run `/research-refine` to create an Idea Freeze and a focused method thesis.
2. Run `/research-blueprint` to create the detailed executable plan.
3. Run `/experiment-plan` only after the blueprint has frozen the claims,
   gates, datasets, baselines, and run order.

The desired durable chain is:

```text
IDEA_CANDIDATES
  -> selected candidate
  -> FINAL_PROPOSAL (Idea Freeze)
  -> RESEARCH_BLUEPRINT (PDF-level executable research plan)
  -> EXPERIMENT_PLAN (operational runbook)
```
