#!/usr/bin/env python3
"""Check debuffer skill inventory drift across mainline, Codex mirror, and docs."""

from __future__ import annotations

import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
SKILLS_ROOT = REPO_ROOT / "skills"
CODEX_ROOT = SKILLS_ROOT / "skills-codex"
LIBRARY_ROOT = SKILLS_ROOT / "library"
CODEX_LIBRARY_ROOT = SKILLS_ROOT / "skills-codex-library"
CATALOG = REPO_ROOT / "docs" / "SKILLS_CATALOG.md"
README = REPO_ROOT / "README.md"
AGENT_GUIDE = REPO_ROOT / "AGENT_GUIDE.md"
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
    ".debuffer_skills",
    ".debuffer_registry",
    ".aris",
    ".agents",
    ".pytest_cache",
    ".pytest_tmp",
    "__pycache__",
    "node_modules",
    ".venv",
    "venv",
}

IGNORED_POLICY_SCAN_PARTS = IGNORED_README_SCAN_PARTS | {
    "skills-codex-claude-review",
    "skills-codex-gemini-review",
}

FORBIDDEN_LIGHTWEIGHT_PATHS = (
    Path("docs/tutorials"),
    Path("community_papers"),
    Path("assets"),
)

ACTIVE_MCP_SERVERS = {"codex-image2", "manual-review"}

MAX_MAIN_PACK_FILE_BYTES = 2_000_000
MAX_ACTIVE_SKILLS = 15


def skill_names(root: Path) -> set[str]:
    return {path.parent.name for path in root.glob("*/SKILL.md")}


def library_skill_names(root: Path) -> set[str]:
    return {path.parent.name for path in root.glob("*/*/SKILL.md")}


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
    return set(re.findall(r"\[`/([^`]+)`\]\(\.\./skills/(?:library/[^/]+/)?[^)]+/SKILL\.md\)", text))


def capability_routes(skill_file: Path) -> list[tuple[str, Path]]:
    text = read(skill_file)
    routes: list[tuple[str, Path]] = []
    for match in re.finditer(r"- `/([^`/]+)`: read `([^`]+/SKILL\.md)`", text):
        routes.append((match.group(1), skill_file.parent / match.group(2)))
    return routes


def check_capability_routing(
    active_root: Path,
    library_root: Path,
    failures: list[str],
) -> None:
    routed: set[str] = set()
    library_root_resolved = library_root.resolve()
    for skill_file in sorted(active_root.glob("*/SKILL.md")):
        text = read(skill_file)
        rel = skill_file.relative_to(REPO_ROOT)
        if "## Capability Routing" not in text:
            failures.append(f"{rel} missing Capability Routing section")
            continue
        routes = capability_routes(skill_file)
        if not routes:
            failures.append(f"{rel} has empty Capability Routing section")
            continue
        for routed_name, target in routes:
            routed.add(routed_name)
            normalized_target = target.resolve()
            if not normalized_target.exists():
                failures.append(f"{rel} routes /{routed_name} to missing file: {target}")
                continue
            if library_root_resolved not in normalized_target.parents:
                failures.append(f"{rel} routes /{routed_name} outside library root: {target}")
            if normalized_target.parent.name != routed_name:
                failures.append(
                    f"{rel} route label /{routed_name} does not match target skill "
                    f"{normalized_target.parent.name}: {target}"
                )
    missing_routed = sorted(routed - library_skill_names(library_root))
    if missing_routed:
        failures.append(f"Capability Routing references unknown library skills: {', '.join(missing_routed)}")


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


def policy_scanned_files() -> list[Path]:
    paths: list[Path] = []
    for path in REPO_ROOT.rglob("*"):
        if not path.is_file():
            continue
        rel = path.relative_to(REPO_ROOT)
        if any(part in IGNORED_POLICY_SCAN_PARTS for part in rel.parts):
            continue
        paths.append(path)
    return paths


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
    library = library_skill_names(LIBRARY_ROOT)
    codex_library = library_skill_names(CODEX_LIBRARY_ROOT)
    all_skills = main | library
    catalog = catalog_names()

    missing_codex = sorted(main - codex)
    extra_codex = sorted(codex - main)
    missing_codex_library = sorted(library - codex_library)
    extra_codex_library = sorted(codex_library - library)
    overlap = sorted(main & library)
    missing_catalog = sorted(all_skills - catalog)
    extra_catalog = sorted(catalog - all_skills)

    require(not missing_codex, f"missing Codex mirrors: {', '.join(missing_codex)}", failures)
    require(not extra_codex, f"unexpected Codex-only skills: {', '.join(extra_codex)}", failures)
    require(not missing_codex_library, f"missing Codex library mirrors: {', '.join(missing_codex_library)}", failures)
    require(not extra_codex_library, f"unexpected Codex-library-only skills: {', '.join(extra_codex_library)}", failures)
    require(not overlap, f"skills appear in both active and library layers: {', '.join(overlap)}", failures)
    require(len(main) <= MAX_ACTIVE_SKILLS, f"active skill layer has {len(main)} skills; expected <= {MAX_ACTIVE_SKILLS}", failures)
    require(not missing_catalog, f"missing catalog entries: {', '.join(missing_catalog)}", failures)
    require(not extra_catalog, f"catalog entries without mainline skills: {', '.join(extra_catalog)}", failures)
    check_capability_routing(SKILLS_ROOT, LIBRARY_ROOT, failures)
    check_capability_routing(CODEX_ROOT, CODEX_LIBRARY_ROOT, failures)

    catalog_text = read(CATALOG)
    readme = read(README)
    agent_guide = read(AGENT_GUIDE)

    expected_count = len(all_skills)
    count_checks = [
        (CATALOG, catalog_text, r"总能力数：\*\*(?P<count>\d+)\*\*"),
        (README, readme, r"总能力数：\*\*(?P<count>\d+)\*\*"),
        (AGENT_GUIDE, agent_guide, r"总能力数：\*\*(?P<count>\d+)\*\*"),
    ]
    for path, text, pattern in count_checks:
        require_count(path, text, pattern, expected_count, failures)

    active_count_checks = [
        (CATALOG, catalog_text, r"默认入口：\*\*(?P<count>\d+)\*\*"),
        (README, readme, r"默认入口：\*\*(?P<count>\d+)\*\*"),
        (AGENT_GUIDE, agent_guide, r"默认入口：\*\*(?P<count>\d+)\*\*"),
    ]
    for path, text, pattern in active_count_checks:
        require_count(path, text, pattern, len(main), failures)
    extra_readmes = readme_like_paths()
    if extra_readmes:
        rels = ", ".join(str(path.relative_to(REPO_ROOT)) for path in extra_readmes)
        failures.append(f"unexpected README-like files; keep only root README.md: {rels}")

    for skill_file in sorted(CODEX_ROOT.glob("*/SKILL.md")) + sorted(CODEX_LIBRARY_ROOT.glob("*/*/SKILL.md")):
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

    docs_files = sorted((REPO_ROOT / "docs").rglob("*")) if (REPO_ROOT / "docs").exists() else []
    docs_file_rels = {
        str(path.relative_to(REPO_ROOT)).replace("\\", "/")
        for path in docs_files
        if path.is_file()
    }
    allowed_docs = {"docs/SKILLS_CATALOG.md", "docs/SKILL_LIBRARY_AUDIT.md"}
    if not docs_file_rels.issubset(allowed_docs):
        failures.append(
            "docs/ contains files outside the compact public docs set; found: "
            + ", ".join(sorted(docs_file_rels))
        )

    for rel in FORBIDDEN_LIGHTWEIGHT_PATHS:
        if (REPO_ROOT / rel).exists():
            failures.append(f"forbidden lightweight-pack path exists: {rel}")

    mcp_root = REPO_ROOT / "mcp-servers"
    active_mcp = {
        path.name
        for path in mcp_root.iterdir()
        if path.is_dir()
    } if mcp_root.exists() else set()
    if active_mcp != ACTIVE_MCP_SERVERS:
        failures.append(
            "mcp-servers/ must contain only active bridges "
            f"{sorted(ACTIVE_MCP_SERVERS)}; found: {sorted(active_mcp)}"
        )

    check_ignore = REPO_ROOT / ".git" / "info" / "exclude"
    gitignore_text = read(REPO_ROOT / ".gitignore")
    local_exclude = check_ignore.read_text(encoding="utf-8") if check_ignore.exists() else ""
    ignore_lines = [
        line.strip().replace("\\", "/").rstrip("/")
        for line in (gitignore_text + "\n" + local_exclude).splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]
    if "archived" in ignore_lines or "archived/**" in ignore_lines or "archived/*" in ignore_lines:
        failures.append("archived/ must stay tracked; do not add it to Git ignore rules")

    for path in policy_scanned_files():
        rel = path.relative_to(REPO_ROOT)
        if path.stat().st_size > MAX_MAIN_PACK_FILE_BYTES:
            failures.append(
                f"large file in main pack ({path.stat().st_size} bytes > "
                f"{MAX_MAIN_PACK_FILE_BYTES}): {rel}"
            )

    required_policy_terms = {
        README: ("profile", "review-prompts/", "AutoDL"),
        AGENT_GUIDE: ("Profile", "prompt-only", "AutoDL"),
        SKILLS_ROOT / "shared-references" / "lightweight-research-pack.md": (
            "Install Profiles",
            "Remote Command Gate",
            "Repository Hygiene",
        ),
        SKILLS_ROOT / "shared-references" / "model-policy.md": (
            "Reviewer interface",
            "Platform profiles",
            "Scheduling and background work",
        ),
    }
    for path, terms in required_policy_terms.items():
        text = read(path)
        for term in terms:
            if term not in text:
                failures.append(f"{path.relative_to(REPO_ROOT)} missing lightweight policy term: {term}")

    # Agent-grant hygiene (WB2): `Agent` in allowed-tools is the Tier-2
    # fan-out capability gate. Per shared-references/fan-out-pattern.md it is
    # granted ONLY to skills that actually fan out, and such skills MUST cite
    # the convention doc in their body. A grant without that citation is a
    # vestigial/boilerplate grant and fails the drift check.
    for skill_file in sorted(SKILLS_ROOT.glob("*/SKILL.md")) + sorted(LIBRARY_ROOT.glob("*/*/SKILL.md")):
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
        print("Skill inventory drift detected:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1
    print("Skill inventory is consistent.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
