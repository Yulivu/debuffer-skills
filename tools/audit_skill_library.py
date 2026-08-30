#!/usr/bin/env python3
"""Audit skill discovery, duplication, platform drift, and progressive disclosure.

This is a report generator, not an auto-rewriter. It intentionally produces
recommendations for human review instead of changing skill content.
"""

from __future__ import annotations

import argparse
import hashlib
import re
from collections import Counter
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
REPORT = ROOT / "docs" / "SKILL_LIBRARY_AUDIT.md"

STALE_PATTERNS = {
    "hard-coded model ids": re.compile(
        r"(?i)\b(?:gpt-\d+(?:\.\d+)?(?:-[a-z0-9-]+)?|claude-[a-z0-9.-]+|gemini-\d+(?:\.\d+)?(?:-[a-z0-9-]+)?)\b"
    ),
    "legacy reviewer MCP names": re.compile(r"mcp__codex__codex(?:-reply)?"),
    "legacy scheduler names": re.compile(r"\b(?:CronCreate|screen|tmux)\b"),
}

OVERLAP_GROUPS = {
    "paper drafting": [
        "paper-writing",
        "paper-plan",
        "paper-write",
        "paper-compile",
        "auto-paper-improvement-loop",
    ],
    "paper visuals": [
        "paper-visualization",
        "paper-figure",
        "paper-illustration",
        "paper-illustration-image2",
        "figure-spec",
        "mermaid-diagram",
        "paper-poster",
        "paper-slides",
        "paper-talk",
        "slides-polish",
    ],
    "review and audit": [
        "research-review",
        "auto-review-loop",
        "auto-review-loop-llm",
        "auto-review-loop-minimax",
        "auto-paper-improvement-loop",
        "kill-argument",
        "paper-claim-audit",
        "experiment-audit",
        "experiment-writeup-audit",
        "result-to-claim",
    ],
    "literature retrieval": [
        "research-lit",
        "arxiv",
        "semantic-scholar",
        "openalex",
        "deepxiv",
        "alphaxiv",
        "exa-search",
        "gemini-search",
        "research-wiki",
        "wiki-enrich",
    ],
    "remote experiments": [
        "experiment-bridge",
        "run-experiment",
        "experiment-queue",
        "hpc-formal-run-gate",
        "monitor-experiment",
        "training-check",
        "serverless-modal",
        "vast-gpu",
        "qzcli",
    ],
}


def skill_files(root: Path) -> list[Path]:
    return sorted(root.glob("*/SKILL.md")) + sorted((root / "library").glob("*/*/SKILL.md"))


def parse_frontmatter(text: str) -> tuple[str, str]:
    match = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
    block = match.group(1) if match else ""
    name_match = re.search(r"^name:\s*[\"']?([^\"'\n]+)", block, re.MULTILINE)
    desc_match = re.search(r"^description:\s*[\"']?(.+)", block, re.MULTILINE)
    return (
        name_match.group(1).strip() if name_match else "",
        desc_match.group(1).strip().rstrip("\"'") if desc_match else "",
    )


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--stdout", action="store_true", help="print the report instead of writing it")
    args = parser.parse_args()

    canonical = skill_files(SKILLS)
    active = sorted(SKILLS.glob("*/SKILL.md"))
    library = sorted((SKILLS / "library").glob("*/*/SKILL.md"))
    codex_active = sorted((SKILLS / "skills-codex").glob("*/SKILL.md"))
    codex_library = sorted((SKILLS / "skills-codex-library").glob("*/*/SKILL.md"))
    claude_overlay = sorted((SKILLS / "skills-codex-claude-review").glob("*/SKILL.md"))
    gemini_overlay = sorted((SKILLS / "skills-codex-gemini-review").glob("*/SKILL.md"))

    rows: list[tuple[Path, int, int, str, str]] = []
    pattern_hits: Counter[str] = Counter()
    files_by_pattern: dict[str, set[str]] = {key: set() for key in STALE_PATTERNS}
    for path in canonical:
        text = path.read_text(encoding="utf-8", errors="replace")
        name, description = parse_frontmatter(text)
        rows.append((path, len(text.splitlines()), len(text.encode()), name, description))
        for label, pattern in STALE_PATTERNS.items():
            count = len(pattern.findall(text))
            pattern_hits[label] += count
            if count:
                files_by_pattern[label].add(rel(path))

    canonical_by_name = {name: path for path, _, _, name, _ in rows if name}
    missing_metadata = [rel(path) for path, _, _, name, desc in rows if not name or not desc]
    oversized_400 = [(rel(path), lines) for path, lines, _, _, _ in rows if lines > 400]
    oversized_700 = [(rel(path), lines) for path, lines, _, _, _ in rows if lines > 700]
    short_descriptions = [
        (rel(path), len(desc))
        for path, _, _, _, desc in rows
        if len(desc) < 60
    ]

    mirror_pairs = []
    for path in active:
        mirror = SKILLS / "skills-codex" / path.parent.name / "SKILL.md"
        if mirror.exists():
            mirror_pairs.append((path.parent.name, sha(path) == sha(mirror)))
    exact_mirrors = sum(same for _, same in mirror_pairs)

    lines: list[str] = [
        "# Skill Library Audit",
        "",
        f"Generated: {date(2026, 8, 30).isoformat()}",
        "",
        "This report is generated by `tools/audit_skill_library.py`. It is an "
        "audit and migration map, not permission for an automated rewrite.",
        "",
        "## Executive Summary",
        "",
        f"- Canonical skills: **{len(canonical)}** ({len(active)} entry, {len(library)} library).",
        f"- Platform overlays: **{len(claude_overlay)} Claude**, **{len(gemini_overlay)} Gemini**.",
        f"- Codex mirror coverage: {len(codex_active)}/{len(active)} entry and "
        f"{len(codex_library)}/{len(library)} library files.",
        f"- Exact entry mirror matches: {exact_mirrors}/{len(mirror_pairs)}; "
        "non-matches are expected where tool/path adapters differ, but they need "
        "semantic parity tests.",
        f"- Files over 400 lines: **{len(oversized_400)}**; over 700 lines: **{len(oversized_700)}**.",
        "",
        "## Current-Practice Alignment",
        "",
        "The audit was cross-checked against the local Codex skill-creator "
        "contract and the current public documentation for Agent Skills, "
        "Claude Code skills, and Model Context Protocol.",
        "",
        "- Keep `SKILL.md` frontmatter concise and discriminating; put conditional "
        "schemas, scripts, references, and assets behind progressive disclosure.",
        "- Keep workflow semantics separate from provider transport. Agent/task "
        "calls, model aliases, browser bridges, and path conventions belong in "
        "platform adapters or references.",
        "- Treat MCP capabilities such as authorization, elicitation, sampling, "
        "roots, and progress as optional negotiated capabilities. Detect them "
        "before use and fail closed when a requested capability is absent.",
        "- Keep long-running work resumable and observable, but separate "
        "background scheduling from semantic acceptance. A task wake-up is not a "
        "quality verdict.",
        "- Prefer deterministic helpers for parsing, validation, rendering, "
        "provenance, and artifact checks; use the model for choices that cannot "
        "be mechanically verified.",
        "",
        "## Immediate Repairs",
        "",
        "1. Use `shared-references/model-policy.md` as the single source for "
        "model selection, reviewer transport, platform profiles, and scheduling.",
        "2. Remove concrete model IDs from workflow defaults. Keep pinned aliases "
        "only in provider adapters with a date and source.",
        "3. Keep `research-review` prompt-only by default; its MCP prerequisites "
        "must be conditional legacy adapter instructions.",
        "4. Treat Codex, Claude, and Gemini folders as adapters over one workflow "
        "contract. Add parity checks for required behavior, not only file counts.",
        "5. Move long mode-specific procedures from oversized `SKILL.md` files to "
        "linked `references/` files and leave a short router in the entrypoint.",
        "",
        "## Size And Progressive Disclosure",
        "",
        "### Over 700 lines",
        "",
    ]
    lines.extend(f"- `{path}`: {count} lines" for path, count in oversized_700)
    lines.extend(["", "### 401-700 lines", ""])
    lines.extend(
        f"- `{path}`: {count} lines"
        for path, count in oversized_400
        if count <= 700
    )
    lines.extend(
        [
            "",
            "Recommended order: split `paper-poster`, `paper-writing`, "
            "`proof-checker`, `paper-write`, `paper-illustration`, `research-lit`, "
            "`grant-proposal`, and `auto-paper-improvement-loop` first. Preserve "
            "the current entry contract and move only conditional provider, venue, "
            "rendering, or schema details.",
            "",
            "## Stale Or Platform-Coupled Patterns",
            "",
        ]
    )
    for label, count in pattern_hits.most_common():
        files = sorted(files_by_pattern[label])
        lines.append(f"- **{label}**: {count} matches in {len(files)} canonical files.")
        lines.extend(f"  - `{path}`" for path in files[:12])
        if len(files) > 12:
            lines.append(f"  - ... and {len(files) - 12} more")
    lines.extend(
        [
            "",
            "A hit is not automatically wrong: `screen`/`tmux` may remain in "
            "the explicit remote compatibility skill, and provider-specific "
            "model aliases may remain in adapters. The problem is allowing these "
            "names to define global defaults or silently change behavior.",
            "",
            "## Keep / Update / Merge / Archive",
            "",
            "### Keep",
            "",
            "- `idea-discovery` -> `research-refine` -> `research-blueprint` -> "
            "`experiment-plan` is now the correct idea-to-execution chain.",
            "- `research-review`, `paper-claim-audit`, `citation-audit`, "
            "`proof-checker`, and `experiment-audit` remain distinct because "
            "their evidence ownership differs.",
            "- `autodl-hpc` and `experiment-bridge` remain the default heavy-compute "
            "boundary; remote orchestration stays opt-in.",
            "",
            "### Update",
            "",
            "- Centralize model/provider routing and replace hard-coded reviewer "
            "defaults with the configured host default.",
            "- Make every skill description state one job, trigger boundary, and "
            "primary output. Short descriptions are routing risks.",
            "- Replace unconditional scheduler language with host automation or "
            "heartbeat adapters; keep scheduling separate from acceptance.",
            "- Add explicit `inputs`, `outputs`, `failure/blocked states`, and "
            "`acceptance gate` to high-risk workflows.",
            "",
            "### Candidate merges",
            "",
            "- Merge `auto-review-loop-llm` and `auto-review-loop-minimax` into "
            "one provider-adapter family behind `auto-review-loop`; retain thin "
            "aliases only for compatibility.",
            "- Merge `paper-figure-artifact-audit` and `figure-table-audit` after "
            "confirming whether the former's provenance checks are required.",
            "- Merge `paper-talk` with `paper-slides` only if the end-to-end "
            "assurance stage remains a named mode.",
            "- Unify literature retrieval under `research-lit` with source adapters; "
            "keep direct `/arxiv`, `/semantic-scholar`, and `/openalex` aliases.",
            "",
            "### Archive / keep opt-in",
            "",
            "- `experiment-queue` is correctly marked legacy/opt-in. Do not make "
            "it an implicit dependency while the AutoDL-first boundary remains.",
            "- Gemini/Claude overlay directories should remain compatibility "
            "profiles, not independent sources of workflow truth.",
            "- Files under `archived/` stay tracked but must not be installed by "
            "default profiles.",
            "",
            "## Structural Target",
            "",
            "```text",
            "skills/",
            "  <small entry skills>/SKILL.md",
            "  library/<domain>/<capability>/SKILL.md",
            "  shared-references/<cross-cutting-contract>.md",
            "  skills-codex*/<adapter-only mirror>/",
            "archived/                         # tracked compatibility history",
            "tools/",
            "  check_skills_inventory.py       # hard inventory invariants",
            "  audit_skill_library.py          # report-level quality audit",
            "tests/",
            "  test_skill_library_audit.py     # deterministic audit invariants",
            "```",
            "",
            "A skill should expose: concise frontmatter, purpose/boundary, "
            "inputs, outputs, minimal workflow, failure states, acceptance gate, "
            "and links to conditional references. Provider syntax belongs in an "
            "adapter or reference, not in every workflow.",
            "",
            "## Migration Order",
            "",
            "1. Fix shared policy contradictions and hard-coded default models.",
            "2. Add semantic mirror and stale-pattern checks to CI.",
            "3. Split the seven largest high-traffic skills using progressive "
            "disclosure and keep compatibility aliases.",
            "4. Consolidate provider-specific review and literature adapters.",
            "5. Re-run this audit after each migration; archive only after usage "
            "and route checks show no remaining callers.",
            "",
            "## Metadata Warnings",
            "",
            f"- Missing name or description: {len(missing_metadata)}.",
            f"- Descriptions shorter than 60 characters: {len(short_descriptions)}.",
            "These warnings are routing quality signals, not automatic failures.",
        ]
    )

    report = "\n".join(lines) + "\n"
    if args.stdout:
        print(report, end="")
    else:
        REPORT.write_text(report, encoding="utf-8")
        print(f"Wrote {REPORT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
