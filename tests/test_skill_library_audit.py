from __future__ import annotations

import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_audit_report_is_reproducible_and_current() -> None:
    result = subprocess.run(
        ["python", "tools/audit_skill_library.py", "--stdout"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert "Canonical skills: **93**" in result.stdout
    assert "Codex mirror coverage: 13/13 entry and 80/80 library files." in result.stdout
    assert "Generated: 2026-08-30" in result.stdout


def test_shared_policy_mirrors_are_identical() -> None:
    for name in ("model-policy.md", "reviewer-routing.md"):
        main = ROOT / "skills" / "shared-references" / name
        codex = ROOT / "skills" / "skills-codex" / "shared-references" / name
        assert main.read_text(encoding="utf-8") == codex.read_text(encoding="utf-8")


def test_review_defaults_do_not_pin_retired_model_ids() -> None:
    paths = [
        ROOT / "skills" / "research-review" / "SKILL.md",
        ROOT / "skills" / "skills-codex" / "research-review" / "SKILL.md",
        ROOT / "skills" / "library" / "review" / "auto-paper-improvement-loop" / "SKILL.md",
        ROOT / "skills" / "skills-codex-library" / "review" / "auto-paper-improvement-loop" / "SKILL.md",
        ROOT / "skills" / "resubmit-pipeline" / "SKILL.md",
        ROOT / "skills" / "skills-codex" / "resubmit-pipeline" / "SKILL.md",
    ]
    for path in paths:
        text = path.read_text(encoding="utf-8")
        assert "REVIEWER_MODEL = `gpt-5.5`" not in text
        assert "REVIEWER_MODEL = `gpt-5.4`" not in text
        assert "REVIEWER_MODEL = gpt-5.5" not in text
        assert "REVIEWER_MODEL = gpt-5.4" not in text
        assert "REVIEWER_MODEL** = `gpt-5.5`" not in text
        assert "REVIEWER_MODEL** = `gpt-5.4`" not in text


def test_research_review_prompt_only_has_no_unconditional_codex_prerequisite() -> None:
    for path in (
        ROOT / "skills" / "research-review" / "SKILL.md",
        ROOT / "skills" / "skills-codex" / "research-review" / "SKILL.md",
    ):
        text = path.read_text(encoding="utf-8")
        assert "Prompt-only review has no provider prerequisite." in text
        assert "REVIEWER_BACKEND = prompt-only" in text
