---
name: interview-cheatsheet
description: Generate a project-local Chinese ML/LLM interview or study cheat sheet without adding tutorial corpora to the skills repo. Uses compact planning, prompt-only review, and optional HTML rendering. Use when the user asks for an interview cheat sheet, study guide, tutorial, quick reference, or "面试速查".
argument-hint: <topic> [--effort compact|balanced|max] [--out-dir docs/generated/tutorials]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Skill
---

# Interview Cheatsheet

Generate one project-local Chinese study artifact for `$ARGUMENTS`.

## Customized Pack Defaults

Read `../../skills-codex/shared-references/lightweight-research-pack.md` first.

- Do not write into this skills repository's `docs/tutorials/`; the bundled
  tutorial corpus was removed to keep the package light.
- Default output directory in a target project:
  `docs/generated/tutorials/<slug>_tutorial.md`.
- Write HTML only if the user asks or if the project already uses rendered
  study notes. Use `docs/generated/tutorials/<slug>_tutorial.html`.
- Review is prompt-only by default: write
  `review-prompts/<slug>_tutorial_review_prompt.md` and ask the user to run it
  in a separate conversation, then consume pasted feedback.
- Keep the artifact scoped. If the topic is too broad, split it before writing.

## Output Contract

Create a single Markdown file unless the user requests rendered HTML:

```text
docs/generated/tutorials/
  <slug>_tutorial.md
  <slug>_tutorial.html        # optional
  <slug>_tutorial.review.json # optional compact audit summary
```

Do not update a tutorial index or commit generated files unless the user
explicitly asks.

## Structure

Use this compact skeleton:

1. TL;DR: 5-7 takeaways.
2. Intuition: why the topic matters and the main mental model.
3. Core formulas: derivations with assumptions and edge cases.
4. From-scratch PyTorch or pseudocode, only if it is useful.
5. Variants and engineering pitfalls.
6. Complexity, memory, and implementation tradeoffs.
7. Comparison table against related methods.
8. 25 interview questions: L1/L2/L3 with collapsible answers.
9. References and verification notes.

## Review Prompt

The prompt-only reviewer should check:

- formula correctness and missing assumptions;
- code executability, shapes, device handling, and numerical stability;
- historical/citation correctness;
- table pipe escaping and Markdown rendering;
- personal-info leaks such as local paths, lab-private names, or machine names;
- whether the guide is too broad for one artifact.

After pasted review arrives, fix blocking issues and write a short audit summary
instead of preserving long review transcripts.
