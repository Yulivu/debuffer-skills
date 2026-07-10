---
name: human-tone
description: Revise and polish academic drafts into clear, direct, human-sounding prose while preserving claims, numbers, citations, limitations, task type, and recommendation stance. Implicitly use when the user says 改写, 改稿, 润色, 润色论文, 像人一点, 更像人写的, 不要AI味, 减少AI味, 不要防御性写作, 去掉防御性表达, 写得自然一点, humanize, less defensive, reduce generic AI-style prose, strengthen an abstract or section, or requests a ResNet, Transformer, BERT, Raft, or MapReduce tone.
---

# Human Tone

## Capability Routing

This is a first-layer entry skill. Keep it loaded as the user-facing route;
when the user asks for revision, polishing, humanization, or less defensive
academic prose, read the routed library skill and follow it directly.

- `/human-tone-core`: read `../library/auxiliary/human-tone-core/SKILL.md`.

Route academic revision requests for: **$ARGUMENTS**

Use `/human-tone-core` for the actual rewrite. This entry exists so default
installs can trigger on natural language such as “改写”, “润色”, “像人一点”,
and “不要防御性写作”.
