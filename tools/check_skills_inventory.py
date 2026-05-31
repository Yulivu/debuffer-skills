#!/usr/bin/env python3
"""Check ARIS skill inventory drift across mainline, Codex mirror, and docs."""

from __future__ import annotations

import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
SKILLS_ROOT = REPO_ROOT / "skills"
CODEX_ROOT = SKILLS_ROOT / "skills-codex"
CATALOG = REPO_ROOT / "docs" / "SKILLS_CATALOG.md"
README = REPO_ROOT / "README.md"
AGENT_GUIDE = REPO_ROOT / "AGENT_GUIDE.md"
ARIS_INTRO = REPO_ROOT / "docs" / "ARIS_INTRO.md"
ARIS_INTRO_HTML = REPO_ROOT / "docs" / "ARIS_INTRO.html"
BOM = b"\xef\xbb\xbf"

FORBIDDEN_CODEX_REVIEWER_STRINGS = (
    "mcp__codex__codex",
    "codex-reply",
    "reviewer-continuation",
    "threadId",
)

# This customized fork keeps one Chinese root README only. These anchors are
# the stable local docs contract used by guides and this inventory check.
REQUIRED_README_ANCHORS = (
    "quick-start",
    "skills-catalog",
    "startup-modes",
    "autodl--gpu",
    "review",
    "maintenance",
    "license",
)

IGNORED_README_SCAN_PARTS = {
    ".git",
    ".aris",
    ".agents",
    ".pytest_cache",
    "__pycache__",
    "node_modules",
    ".venv",
    "venv",
}


def skill_names(root: Path) -> set[str]:
    return {path.parent.name for path in root.glob("*/SKILL.md")}


def allowed_tools(text: str) -> list[str]:
    """Tokens on the frontmatter `allowed-tools:` line (empty if absent)."""
    match = re.search(r"^allowed-tools:\s*(.+)$", text, flags=re.MULTILINE)
    if not match:
        return []
    return [tok.strip() for tok in match.group(1).split(",") if tok.strip()]


def frontmatter_split(text: str) -> str:
    """Return the body after a leading YAML frontmatter block.

    Anchors on the opening `---` fence and the first closing `---` fence, so
    later horizontal rules are not mistaken for the frontmatter boundary.
    """
    match = re.match(r"^---\n.*?\n---\n", text, flags=re.DOTALL)
    return text[match.end():] if match else text


def readme_anchors(text: str) -> set[str]:
    return set(re.findall(r'<a id="([^"]+)"></a>', text))


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def catalog_names() -> set[str]:
    text = read(CATALOG)
    return set(re.findall(r"\[`/([^`]+)`\]\(\.\./skills/[^)]+/SKILL\.md\)", text))


def readme_like_paths() -> list[Path]:
    paths: list[Path] = []
    for path in REPO_ROOT.rglob("*"):
        if not path.is_file():
            continue
        rel = path.relative_to(REPO_ROOT)
        if any(part in IGNORED_README_SCAN_PARTS for part in rel.parts):
            continue
        if "readme" in path.name.lower() and path != README:
            paths.append(path)
    return sorted(paths)


def require(condition: bool, message: str, failures: list[str]) -> None:
    if not condition:
        failures.append(message)


def require_count(path: Path, text: str, pattern: str, expected_count: int, failures: list[str]) -> None:
    match = re.search(pattern, text)
    rel = path.relative_to(REPO_ROOT)
    if match is None:
        failures.append(f"{rel} is missing live count pattern: {pattern}")
        return
    actual = int(match.group("count"))
    if actual != expected_count:
        failures.append(f"{rel} reports {actual} skills; expected {expected_count}")


def check_inventory() -> list[str]:
    failures: list[str] = []
    main = skill_names(SKILLS_ROOT)
    codex = skill_names(CODEX_ROOT)
    catalog = catalog_names()

    missing_codex = sorted(main - codex)
    extra_codex = sorted(codex - main)
    missing_catalog = sorted(main - catalog)
    extra_catalog = sorted(catalog - main)

    require(not missing_codex, f"missing Codex mirrors: {', '.join(missing_codex)}", failures)
    require(not extra_codex, f"unexpected Codex-only skills: {', '.join(extra_codex)}", failures)
    require(not missing_catalog, f"missing catalog entries: {', '.join(missing_catalog)}", failures)
    require(not extra_catalog, f"catalog entries without mainline skills: {', '.join(extra_catalog)}", failures)

    catalog_text = read(CATALOG)
    readme = read(README)
    agent_guide = read(AGENT_GUIDE)
    aris_intro = read(ARIS_INTRO)
    aris_intro_html = read(ARIS_INTRO_HTML)

    expected_count = len(main)
    count_checks = [
        (CATALOG, catalog_text, r"\*\*(?P<count>\d+) skills\*\*"),
        (README, readme, r"包含 \*\*(?P<count>\d+) 个 skill\*\*"),
        (README, readme, r"主线与 Codex mirror 均为 \*\*(?P<count>\d+) 个 skill\*\*"),
        (AGENT_GUIDE, agent_guide, r"Full catalog.*?\*\*(?P<count>\d+) skills\*\*"),
        (ARIS_INTRO, aris_intro, r"collection of \*\*(?P<count>\d+) composable Claude Code skills\*\*"),
        (ARIS_INTRO, aris_intro, r"## The (?P<count>\d+) Skills"),
        (ARIS_INTRO, aris_intro, r"一组 (?P<count>\d+) 个可组合的 Claude Code skills"),
        (ARIS_INTRO_HTML, aris_intro_html, r"collection of <strong>(?P<count>\d+) composable Claude Code skills</strong>"),
        (ARIS_INTRO_HTML, aris_intro_html, r'id="the-(?P<count>\d+)-skills"'),
        (ARIS_INTRO_HTML, aris_intro_html, r"一组 (?P<count>\d+) 个可组合的 Claude Code skills"),
    ]
    for path, text, pattern in count_checks:
        require_count(path, text, pattern, expected_count, failures)

    extra_readmes = readme_like_paths()
    if extra_readmes:
        rels = ", ".join(str(path.relative_to(REPO_ROOT)) for path in extra_readmes)
        failures.append(f"unexpected README-like files; keep only root README.md: {rels}")

    for skill_file in sorted(CODEX_ROOT.glob("*/SKILL.md")):
        if skill_file.read_bytes().startswith(BOM):
            failures.append(f"{skill_file.relative_to(REPO_ROOT)} starts with UTF-8 BOM before frontmatter")
        text = read(skill_file)
        for forbidden in FORBIDDEN_CODEX_REVIEWER_STRINGS:
            if forbidden in text:
                failures.append(f"{skill_file.relative_to(REPO_ROOT)} contains forbidden reviewer string: {forbidden}")

    anchors = readme_anchors(readme)
    for required in REQUIRED_README_ANCHORS:
        if required not in anchors:
            failures.append(f"README.md missing required anchor: <a id=\"{required}\"></a>")

    # Agent-grant hygiene (WB2): `Agent` in allowed-tools is the Tier-2
    # fan-out capability gate. Per shared-references/fan-out-pattern.md it is
    # granted ONLY to skills that actually fan out, and such skills MUST cite
    # the convention doc in their body. A grant without that citation is a
    # vestigial/boilerplate grant and fails the drift check.
    for skill_file in sorted(SKILLS_ROOT.glob("*/SKILL.md")):
        text = read(skill_file)
        if "Agent" not in allowed_tools(text):
            continue
        if "fan-out-pattern.md" not in frontmatter_split(text):
            rel = skill_file.relative_to(REPO_ROOT)
            failures.append(
                f"{rel} grants `Agent` in allowed-tools but its body does not "
                f"cite fan-out-pattern.md — vestigial grant or undocumented "
                f"fan-out (see shared-references/fan-out-pattern.md)"
            )

    return failures


def main() -> int:
    failures = check_inventory()
    if failures:
        print("ARIS skill inventory drift detected:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1
    print("ARIS skill inventory is consistent.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
