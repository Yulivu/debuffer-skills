# Model, Provider, And Runtime Policy

This is the single policy for model and reviewer selection across the skill
pack. Skill instructions describe the task and the required reviewer contract;
the host configuration or an explicit user option selects the concrete model.

## Defaults

- Do not hard-code a model ID as a workflow default. Use the current host or
  provider default and record the resolved model in the run trace.
- A user-provided model or provider override is honored only for that run. It
  must not become a new default in a generated artifact or a skill file.
- `reasoning_effort` / `thinking` is a capability setting, not a model name.
  Use the host-supported value and report when a requested value is unavailable.
- A model alias that is required by a third-party API may appear in the
  adapter reference, but it must be labeled `pinned`, include a date and source,
  and never be used as the general reviewer default.

## Reviewer interface

Review-capable workflows should reason in terms of this abstract contract:

```text
new_review_thread(prompt, files, reviewer, effort, fresh_context)
continue_review_thread(thread_handle, prompt, files, reviewer, effort)
```

The concrete transport may be a prompt-only handoff, a Codex task, a manual
review page, or another configured provider. Save the transport, resolved
model, effort, thread/task handle, and raw response path in the trace.

- Prompt-only is the default for external quality review in the lightweight
  pack.
- Automatic reviewer calls require explicit opt-in and an available adapter.
- A missing requested adapter is an explicit blocked state. Do not silently
  switch model families or claim that a review happened.
- A fresh review means the reviewer receives the artifact and task prompt, not
  the executor's private reasoning or an earlier score summary. Thread
  continuation is allowed only when the workflow explicitly requires it.

See `reviewer-routing.md`, `reviewer-independence.md`, and
`review-tracing.md` for the acceptance and evidence rules.

## Platform profiles

Keep workflow semantics platform-neutral. Platform-specific files may adapt:

- tool names and invocation syntax;
- path resolution and installation layout;
- task/thread continuation APIs;
- image or browser capabilities.

They must not silently change claim boundaries, evidence gates, acceptance
ownership, or remote-command approval rules.

Supported profiles in this repository are `codex`, `claude`, `gemini`, and
`prompt-only`. An unrecognized profile fails closed and asks for configuration.

## Scheduling and background work

Scheduling controls when a task wakes up; it never decides correctness,
novelty, quality, or publication acceptance. Use the host's current automation
or heartbeat facility when available. Mention legacy scheduler commands only
inside a clearly marked compatibility adapter.
