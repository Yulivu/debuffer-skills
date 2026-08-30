# AutoSci-Lite Patterns

Use these patterns when a project has little inspiration, needs idea memory, or
is moving from proposal to experiments. They adapt useful AutoSci workflow
ideas to this lightweight, AutoDL-first pack. Do not import AutoSci's full wiki,
MCP reviewer, or SSH automation.

## Skill Boundaries

- `idea-creator` owns A-E candidate generation, idea ranking, and compact
  updates to `idea-stage/IDEA_MEMORY.md`.
- `idea-discovery` is only the end-to-end orchestrator. It should pass the
  landscape, startup mode, reference-paper/code context, and venue constraints
  into `idea-creator` instead of re-describing A-E generation itself.
- `idea-discovery` ends at a user-selected, evidence-bounded candidate. It does
  not silently produce a full method proposal or executable research plan.
- `research-refine` owns **Idea Freeze**: the immutable Problem Anchor, one
  dominant method thesis, explicit non-goals, minimum mechanism checks, and
  kill/pivot condition.
- `research-blueprint` owns the **Executable Research Plan**: PDF-level
  positioning, raw-idea corrections, method layers, theory obligations,
  capability matrix, task/query protocol, claim map, numeric gates, timeline,
  implementation plan, risk register, and paper package.
- `research-refine` may borrow A-E paths as route-selection lenses after a
  problem or candidate idea exists. It should not run a broad idea search; if
  the task still needs new candidates, hand off to `idea-creator`.
- `idea-discovery` robotics mode adds embodied-AI constraints and then
  delegates candidate generation to `idea-creator`.
- `experiment-plan` and `autodl-hpc` own pilot gates, smoke/formal run
  separation, and experiment-level negative memory after an idea is selected.

## A-E Idea Paths

When generating or refining ideas, produce candidates across these paths when
the available material allows it. Each candidate should record `path`, `source`,
`hypothesis`, `minimal validation`, and `failure risk`.

| Path | Name | Use When | Candidate Shape |
|---|---|---|---|
| A | Landscape-driven | Only a venue, topic, or broad direction is known. | Design directly from the current landscape, open problem, or venue gap. |
| B | Incremental | A reference paper, method, or codebase has a clear limitation. | Fix limitation L in method M with the smallest adequate mechanism. |
| C | Combination | Two methods have complementary strengths or tradeoffs. | Combine M1 and M2 only if the hybrid has a testable reason to be better. |
| D | Assumption-breaking | Several methods share a brittle assumption. | Break assumption P and test a setting where existing methods should fail. |
| E | Cross-domain transfer | Another field has a mechanism matching the current bottleneck. | Transfer mechanism M from domain X to Y with an explicit adaptation boundary. |

Do not force all five paths into every project. For sparse starts, generate at
least one candidate for A and one candidate for any available B-E path. For
reference-heavy starts, prefer B-D before A. For cross-domain prompts, require
path E candidates to name both domains and the transferable mechanism.

## Lightweight Failure Memory

Keep negative memory compact and append-only by default:

```text
idea-stage/IDEA_MEMORY.md
experiments/NEGATIVE_RESULTS.md
```

`idea-stage/IDEA_MEMORY.md` records idea-level outcomes:

```markdown
## YYYY-MM-DD - <idea slug or short title>
- Path: A|B|C|D|E
- Status: proposed|active|rejected|pilot-pass|pilot-fail|inconclusive
- Reason: <specific reason, not "bad idea">
- Do not repeat: <what future sessions should avoid>
- Revisit if: <new evidence that would make it worth retrying>
```

`experiments/NEGATIVE_RESULTS.md` records failed or inconclusive experiments:

```markdown
## YYYY-MM-DD - <run or experiment id>
- Claim tested:
- Setup / suite:
- Outcome: failed|inconclusive|regressed|crashed
- Failure reason:
- Artifact path:
- Decision: abandon|revise method|revise protocol|rerun with fix
```

Before generating new ideas or experiment plans, scan these two files if they
exist and treat them as a banlist. Avoid repeated directions unless the user
explicitly asks to revisit them or the `Revisit if` condition is satisfied.

## Pilot Gate

Before formal AutoDL/HPC runs, create a pilot gate unless the user explicitly
waives it or the project already has equivalent smoke evidence.

Pilot purpose: detect obvious collapse, data/config incompatibility, severe
baseline regression, or missing instrumentation. It is not paper evidence.

Minimum pilot spec:

```markdown
# Pilot Spec: <slug>

- Claim or risk tested:
- Dataset / subset:
- Baseline included:
- Proposed variant:
- Metrics:
- Reduced budget: <steps/epochs/subset/seeds>
- Pass condition: no obvious collapse and metrics are plausible.
- Fail condition: divergence, crash, severe regression, or impossible setup.
- Output path: experiments/runs/pilot/<slug>/
- AutoDL handoff: <command block or suite path>
```

If GPU time is needed, write an AutoDL-ready pilot command block and wait for
approval or pasted results. Do not run SSH, `screen`, `tmux`, or formal suites
automatically.

Pilot verdicts:

- `pilot-pass`: proceed to experiment protocol or AutoDL smoke.
- `pilot-fail`: record `experiments/NEGATIVE_RESULTS.md` and update
  `idea-stage/IDEA_MEMORY.md`.
- `inconclusive`: either narrow the pilot or proceed with explicit risk.

## Macro State Machine

Use this map in `PROJECT_STATUS.md`:

```text
direction -> idea -> method -> repo scaffold -> experiment protocol -> local smoke -> AutoDL smoke -> formal runs -> evidence audit -> paper plan -> manuscript -> submission
```

Required fields:

```markdown
# Project Status

- Current phase:
- Startup mode:
- Target venue:
- Active idea / method:
- Last accepted artifact:
- Next gate:
- Blockers:
- Phase map: direction -> idea -> method -> repo scaffold -> [experiment protocol] -> local smoke -> AutoDL smoke -> formal runs -> evidence audit -> paper plan -> manuscript -> submission
```

Update the current phase only at accepted stage gates. If a phase regresses
because a pilot or audit failed, keep the map honest and record the reason in
`NEXT_ACTIONS.md` plus the relevant failure-memory file.
