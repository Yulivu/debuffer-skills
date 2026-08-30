# Reviewer Routing

Read `model-policy.md` before selecting a reviewer. This file defines the
transport rules; it does not pin a global model or reasoning level.

## Default

External quality review is **prompt-only** in the lightweight pack:

1. Write the exact reviewer prompt under `review-prompts/`.
2. Ask the user to run it in a separate conversation with the model they
   choose.
3. Consume the pasted response and record the prompt, response, and summary
   under `review-stage/`.

This default is deliberately independent of any provider subscription.

## Explicit automatic backends

Only when the user explicitly selects a backend and the corresponding adapter
is available:

- `codex`: create a fresh review task/thread for round 1; use continuation only
  when the skill's protocol requires it.
- `manual`: open the configured manual-review page or file handoff. The user
  must choose a reviewer from a different model family for a quality verdict.
- `oracle-pro` or another named provider: use the configured provider adapter
  and record the resolved model alias in the trace. Do not assume that a model
  alias remains available.

If a requested adapter is missing, stop with an explicit blocked message.
Never silently fall back to a different model family, claim that a review
happened, or convert a failed review into an acceptance.

## Common routing contract

Every reviewer-capable skill should record:

```text
backend, resolved_model, effort, fresh_context, thread_or_task_handle,
prompt_path, raw_response_path, verdict_id
```

- `fresh_context=true` means the reviewer sees the artifact and prompt, not
  executor reasoning or a prior score summary.
- A continuation handle is allowed only for a declared multi-round protocol.
- Quality, novelty, correctness, and publication decisions require a
  cross-model reviewer or a deterministic verifier, as defined in
  `acceptance-gate.md`.
- Scheduling and heartbeat tools can wake a workflow, but cannot accept its
  output.

## Platform adapters

Canonical workflow instructions must stay platform-neutral. Codex, Claude, and
other mirrors may translate the abstract operations above into their local
tool names and path conventions. Keep those translations in the mirror or a
provider reference; do not copy them into every canonical skill.
