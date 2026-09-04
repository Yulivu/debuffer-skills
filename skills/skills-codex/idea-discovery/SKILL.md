---
name: "idea-discovery"
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

- `/idea-creator`: read `../../skills-codex-library/idea-method/idea-creator/SKILL.md`.
- `/reference-paper-deconstruction`: read `../../skills-codex-library/idea-method/reference-paper-deconstruction/SKILL.md`.
- `/method-paper-gate`: read `../../skills-codex-library/idea-method/method-paper-gate/SKILL.md`.
- `/research-lit`: read `../../skills-codex-library/literature/research-lit/SKILL.md`.
- `/novelty-check`: read `../../skills-codex-library/review/novelty-check/SKILL.md`.
- `/research-refine`: read `../../skills-codex-library/idea-method/research-refine/SKILL.md` only after a candidate is selected.
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
  -> research-refine (Idea Freeze)
  -> research-blueprint (Executable Research Plan)
```

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
- `MAX_CANDIDATES = 12`.
- `MAX_SELECTED = 1` unless parallel tracks are explicitly requested.
- `PILOT = opt-in`: prepare a pilot spec only when requested.
- `OUTPUT_DIR = idea-stage/`.

## Phase 0: Load Context

Read, when present:

1. `docs/project/RESEARCH_BRIEF.md` or legacy `RESEARCH_BRIEF.md`.
2. `PROJECT_STATUS.md` and `docs/project/NEXT_ACTIONS.md`.
3. `research-wiki/query_pack.md`.
4. `idea-stage/IDEA_MEMORY.md` and `experiments/NEGATIVE_RESULTS.md`.
5. Local papers, codebase notes, or a supplied reference PDF.

This phase is the **Load Research Brief** step. Preserve the user's constraints
separately from reference-document content. The Research Brief is context, not
permission to copy claims or methods.

## Phase 1: Landscape and Reference Deconstruction

If a reference paper or small paper set is supplied, run
`/reference-paper-deconstruction` first. Preserve source locators, the actual
question, conclusion boundary, reusable structure, missing evidence, and the
minimum discriminating test. Then run `/research-lit` to test the gap against
recent work.

Organize the result by problem, method family, competing explanation, failure
mode, shared assumption, and unexplored regime. Do not call a gap open merely
because a paper says “future work”.

## Phase 2: Candidate Generation

Invoke `/idea-creator` with the landscape, constraints, provenance, and failure
memory. The creator owns the A-E paths:

```text
A landscape-driven
B incremental limitation repair
C justified combination
D assumption-breaking
E cross-domain transfer
```

Every candidate needs a precise question, hypothesis, importance, closest work,
minimum discriminating test, paper type (`method-primary`,
`audit-support`, or `audit-only`), method delta, resource estimate, failure
condition, evidence status, and conclusion boundary.

Do not produce a full architecture, theorem suite, 16-week plan, or paper figure
list here unless explicitly requested.

## Phase 3: Mechanical Consolidation

Remove only near-duplicates and objectively impossible candidates. Preserve
uncertainty as annotations. Do not eliminate a candidate merely because it is
difficult or not yet verified as novel.

## Phase 4: Novelty and Adversarial Review

Run `/novelty-check` on the strongest candidates and use `/research-review` or
an external review package for criticism. Preserve `review-tracing.md` whenever
an external reviewer is used. Ask for the closest work, strongest objection,
discriminating result, importance under failure, and smallest repair.

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

- `idea-stage/IDEA_CANDIDATES.md`;
- `idea-stage/IDEA_REPORT.md`;
- `idea-stage/IDEA_MEMORY.md` using the **Write Ideas to Research Wiki** and
  append-only memory conventions when the project has a research wiki.

Use this schema:

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
- Evidence status:
- Conclusion boundary:
- Next action:
```

Stop and ask the user to select one candidate. No response is not approval.

## Handoff

After selection:

1. `/research-refine` creates the Idea Freeze and focused method thesis.
2. `/research-blueprint` creates the detailed executable research plan.
3. `/experiment-plan` creates the operational runbook after the blueprint gate.

Durable chain:

```text
IDEA_CANDIDATES -> FINAL_PROPOSAL -> RESEARCH_BLUEPRINT -> EXPERIMENT_PLAN
```
