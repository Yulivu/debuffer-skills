---
name: human-tone-core
description: Apply anti-defensive editing and curated classic-paper structures to revise academic prose into clear, direct, human-sounding writing while preserving claims, numbers, citations, limitations, task type, and recommendation stance. Use when a higher-level skill routes revision, polishing, or humanization work here.
---

# Human Tone Core

Revise academic prose with a direct authorial posture and a suitable
classic-paper structure, not a named author's personal voice.

## Workflow

1. Identify the deliverable: paper section, abstract, review, rebuttal, or other prose.
2. Preserve the input language unless translation is requested.
3. Run the anti-defensive pass below.
4. Use the requested preset, or select the closest preset below.
5. Rewrite without expanding the factual scope.
6. Return only the revised text unless analysis is requested.

## Anti-Defensive Pass

- Advance the claim directly instead of negotiating with an imagined critic.
- Delete disclaimers that add no evidence, scope, logic, precision, or reader guidance.
- Convert negative scope into positive scope: state what the paper studies, tests, or supports.
- Replace stacked hedges with precise uncertainty tied to evidence, design, sample, or measurement.
- Keep real methodological, ethical, legal, safety, and validity limits. State each necessary limit once and place it where it matters.
- Remove apology-like framing, repeated “not X but Y” constructions, self-undermining contribution claims, and over-explanations added only to prevent hypothetical misunderstanding.
- Rebuild each paragraph around one main job: claim, mechanism, evidence, implication, or limitation.

## Presets

| Preset | Reference pattern | Best for | Behavior |
|---|---|---|---|
| `balanced-classic` | Conservative blend | Reviews and unclear requests | State the main point early, keep decisive details, vary sentence length, and avoid exhaustive template coverage. |
| `resnet-direct` | *Deep Residual Learning for Image Recognition* | Vision, methods, results | Name the problem, give the mechanism plainly, support it with a few concrete results, and keep conclusions restrained. |
| `transformer-contrast` | *Attention Is All You Need* | Abstracts, introductions, architectures | Contrast the dominant approach with one limitation, introduce the simpler alternative, then give decisive quality and efficiency evidence. |
| `bert-empirical` | *BERT* | NLP/LLM and broad evaluation | Define the model compactly, explain the training distinction, then emphasize minimal adaptation and breadth of empirical gains. |
| `raft-clarity` | *In Search of an Understandable Consensus Algorithm* | Protocols and mechanism-heavy systems | Lead with the design goal, decompose the mechanism, explain why each part exists, then validate correctness and practicality. |
| `mapreduce-system` | *MapReduce* | Infrastructure and distributed systems | Define the abstraction, separate user logic from runtime duties, then show scale, fault handling, and practical usefulness. |

Default to `balanced-classic` for reviews, `resnet-direct` for result-heavy vision text, `transformer-contrast` for abstracts and introductions, `bert-empirical` for NLP/LLM work, `raft-clarity` for protocols, and `mapreduce-system` for infrastructure abstractions.

## Rules

- Preserve claims, numbers, equations, citations, terminology, limitations, recommendation, and confidence.
- Preserve the document function. An `Overall Recommendation Review Text` remains a review, not a paper summary or a response to the style example.
- Treat reference text as style evidence only; do not copy its facts into the target.
- Do not add datasets, baselines, hyperparameters, experiments, strengths, weaknesses, or conclusions absent from the evidence.
- Prefer one clear contribution thread over a comprehensive inventory.
- Remove generic openings, repetitive summaries, inflated adjectives, symmetrical list-like prose, and unnecessary transitions.
- Use concrete nouns and verbs. Keep English technical terms when they are more precise.
- Create natural cadence through sentence length and emphasis, not typos, grammar errors, fake uncertainty, or factual defects.
- Preserve genuine uncertainty with restrained wording or direct questions instead of inventing an answer.
- Never strengthen a claim beyond its evidence while removing hedges.
- Derive only high-level structure from reference papers. Do not copy distinctive phrases or claim exact author imitation.
- Do not promise a lower AI-detection score; optimize for specific, evidence-grounded academic writing.

## Review Mode

- Start from the reviewer's actual understanding and overall judgment.
- Keep strengths selective; two or three supported points are usually enough.
- Tie weaknesses to evidence, figures, definitions, or reproducibility.
- Use wording such as “我认为”, “我更感觉”, “好像”, or question forms only when the source contains genuine uncertainty.
- Do not remove reviewer uncertainty merely to make the review sound more confident.
- Keep the requested recommendation and confidence unless reconsideration is explicitly requested.
- Do not add standard review sections merely to make the response look complete.

## Final Check

Verify that the output performs the requested task, every fact is supported, no
number or verdict changed, the preset appears through structure rather than
copied wording, and the rewrite does not expand scope unless asked.
