# External Cadence

External schedulers decide when an agent wakes. They do not decide correctness,
quality, novelty, or acceptance.

## Safe Use

Use an opt-in overnight heartbeat only for machine-checkable external facts:
job exit, artifact arrival, process liveness, resource availability, or a
scheduled literature update. It may resume a stalled phase without changing its
contract, record the wake event, or notify the user.

Do not use a timer to rerun an internal reviewer loop. Do not duplicate an
internal scheduler. Do not use a heartbeat to accept a claim, idea, paper,
proof, or result.

One-line rule: **a heartbeat may say "keep going," never "good enough."**
