# Research Integrity and Automation Boundaries

## Purpose

Keep automation from turning a research workflow into a self-acquitting loop.
Automation may collect evidence, run bounded procedures, resume work, and
record state. It may not silently decide that a claim is novel, correct,
supported, or ready for submission.

## Append-Only Evidence

For every verdict-bearing task, preserve the exact inputs, complete external
review text, extracted findings, changes, next verification result, and final
status. Do not delete a finding because a later draft no longer mentions it.
Mark it `resolved`, `superseded`, `not-reproducible`, or `unresolved`, and retain
the source and rationale.

## Anti-Automation Audit

Before accepting a verdict-bearing loop, check that the executor did not:

1. rewrite claims until a checker stopped complaining;
2. hide or summarize away unfavorable reviewer evidence;
3. change problem, data, metric, or scope without a new version;
4. use the executor as the independent adjudicator;
5. treat a high score as acceptance when the verdict is negative;
6. convert missing evidence into a positive assumption;
7. change a failed experiment's protocol without recording the change;
8. erase unresolved obligations from the report.

`clean` means no integrity violation was found in the inspected artifacts. It
does not mean that the research is correct or publishable.

## Verdict Independence

Keep executor, reviewer, and acceptance gate distinct. The executor may mark an
artifact `done`; it may not mark a quality or correctness phase `accepted` from
its own summary. Acceptance must reference an independent verdict or a
deterministic verifier.

## Reviewer Loop Rules

Every automatic reviewer loop has a fixed round limit, preserves round identity
and prior findings, saves the complete raw response, defines allowed fix classes
before starting, stops on a registered condition or the round limit, and records
unresolved findings at termination. A scope, data, metric, or claim change
requires a fresh audit.

An automatic positive stop ends the loop. It does not accept an idea, authorize
a test readout, approve a paper, or change the research phase.

## External Cadence Rules

An overnight heartbeat may inspect machine-checkable external facts such as job
exit, artifact arrival, process liveness, resource availability, or a scheduled
literature update. It may resume a stalled phase or notify the user.

It must not rerun a verdict-bearing loop merely because a timer fired, compete
with an internal scheduler, accept a claim or paper, change scope or evaluation
rules, or bypass user approval.

One-line rule: **automation may drive the workflow, but it may not acquit it.**
