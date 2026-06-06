from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path

import pytest


REPO_ROOT = Path(__file__).resolve().parents[1]
INSTALL_PS1 = REPO_ROOT / "tools" / "install_aris.ps1"
RECONCILE_PS1 = REPO_ROOT / "tools" / "reconcile_debuffer_installs.ps1"
GUI_PS1 = REPO_ROOT / "tools" / "install_debuffer_gui.ps1"
REPO_UPDATE_PS1 = REPO_ROOT / "tools" / "update_debuffer_repo.ps1"


def resolve_powershell() -> str | None:
    override = os.environ.get("ARIS_TEST_POWERSHELL")
    if override:
        return shutil.which(override) or override
    return shutil.which("pwsh") or shutil.which("powershell") or shutil.which("powershell.exe")


PS_EXE = resolve_powershell()

pytestmark = pytest.mark.skipif(
    os.name != "nt" or PS_EXE is None,
    reason="install_aris.ps1 manages Windows junctions via Windows PowerShell",
)


def run_ps(
    args: list[str],
    *,
    check: bool = True,
    script: Path = INSTALL_PS1,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [PS_EXE, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(script), *args],
        cwd=REPO_ROOT,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=check,
        env=env,
    )


def ps_value(command: str) -> str:
    result = subprocess.run(
        [PS_EXE, "-NoProfile", "-Command", command],
        cwd=REPO_ROOT,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=True,
    )
    return result.stdout.strip()


def path_item_exists(path: Path) -> bool:
    command = f"if (Get-Item -LiteralPath '{path}' -Force -ErrorAction SilentlyContinue) {{ 'true' }} else {{ 'false' }}"
    return ps_value(command) == "true"


def junction_target(path: Path) -> Path:
    target = ps_value(f"(Get-Item -LiteralPath '{path}' -Force).Target")
    return Path(target)


def junction_type(path: Path) -> str:
    return ps_value(f"(Get-Item -LiteralPath '{path}' -Force).LinkType")


def make_junction(path: Path, target: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    ps_value(f"New-Item -ItemType Junction -Path '{path}' -Target '{target}' | Out-Null")


def remove_link(path: Path) -> None:
    ps_value(f"[System.IO.Directory]::Delete('{path}', $false)")


def make_skill(path: Path, body: str = "# skill\n") -> None:
    path.mkdir(parents=True, exist_ok=True)
    (path / "SKILL.md").write_text(body, encoding="utf-8")


def make_minimal_repo(root: Path) -> Path:
    repo = root / "aris"
    make_skill(repo / "skills" / "alpha", "# claude alpha\n")
    make_skill(repo / "skills" / "beta", "# claude beta\n")
    make_skill(repo / "skills" / "skills-codex" / "alpha", "# codex alpha\n")
    make_skill(repo / "skills" / "skills-codex" / "beta", "# codex beta\n")
    make_skill(repo / "skills" / "skills-codex-claude-review" / "alpha", "# overlay alpha\n")
    (repo / "skills" / "shared-references").mkdir(parents=True)
    (repo / "skills" / "shared-references" / "routing.md").write_text("claude support\n", encoding="utf-8")
    (repo / "skills" / "skills-codex" / "shared-references").mkdir(parents=True)
    (repo / "skills" / "skills-codex" / "shared-references" / "routing.md").write_text(
        "codex support\n", encoding="utf-8"
    )
    (repo / "tools").mkdir(parents=True)
    (repo / "tools" / "helper.py").write_text("# helper\n", encoding="utf-8")
    return repo


def test_install_aris_ps1_codex_dry_run_has_no_project_writes(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()

    result = run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-DryRun"])

    assert "DRY-RUN" in result.stdout
    assert not (project / ".debuffer_skills").exists()
    assert not (project / ".agents").exists()
    assert not (project / "AGENTS.md").exists()


def test_install_aris_ps1_codex_apply_reconcile_and_uninstall(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo)])

    manifest = project / ".debuffer_skills" / "installed-skills-codex.txt"
    assert manifest.exists()
    manifest_text = manifest.read_text(encoding="utf-8")
    assert f"repo_root\t{repo}" in manifest_text
    assert "\tskills/skills-codex/alpha\t.agents/skills/alpha\tjunction" in manifest_text
    assert junction_type(project / ".agents" / "skills" / "alpha") == "Junction"
    assert junction_target(project / ".agents" / "skills" / "alpha") == repo / "skills" / "skills-codex" / "alpha"
    assert junction_target(project / ".agents" / "skills" / "shared-references") == (
        repo / "skills" / "skills-codex" / "shared-references"
    )
    assert junction_type(project / ".debuffer_skills" / "tools") == "Junction"
    assert junction_target(project / ".debuffer_skills" / "tools") == repo / "tools"
    agents_text = (project / "AGENTS.md").read_text(encoding="utf-8")
    assert "debuffer Codex Skill Scope" in agents_text
    assert ".agents/skills/<skill-name>" in agents_text
    assert ".agents/skills/aris" not in agents_text

    (project / ".agents" / "skills" / "local-only").mkdir()
    (repo / "skills" / "skills-codex" / "alpha" / "SKILL.md").unlink()
    (repo / "skills" / "skills-codex" / "alpha").rmdir()
    make_skill(repo / "skills" / "skills-codex" / "gamma", "# codex gamma\n")

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-Reconcile"])

    assert not path_item_exists(project / ".agents" / "skills" / "alpha")
    assert junction_target(project / ".agents" / "skills" / "gamma") == repo / "skills" / "skills-codex" / "gamma"
    assert (project / ".agents" / "skills" / "local-only").exists()

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-Uninstall", "-DryRun"])
    assert (project / ".debuffer_skills" / "installed-skills-codex.txt").exists()
    assert "debuffer Codex Skill Scope" in (project / "AGENTS.md").read_text(encoding="utf-8")

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-Uninstall"])

    assert (project / ".agents" / "skills" / "local-only").exists()
    assert not (project / ".agents" / "skills" / "beta").exists()
    assert not (project / ".debuffer_skills" / "tools").exists()
    assert not (project / ".debuffer_skills" / "installed-skills-codex.txt").exists()
    assert (project / ".debuffer_skills" / "installed-skills-codex.txt.prev").exists()
    assert "debuffer Codex Skill Scope" not in (project / "AGENTS.md").read_text(encoding="utf-8")


def test_install_aris_ps1_updates_local_registry(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()
    registry = tmp_path / "registry" / "installed-projects.tsv"
    env = {**os.environ, "DEBUFFER_REGISTRY_PATH": str(registry)}

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo)], env=env)

    registry_text = registry.read_text(encoding="utf-8")
    assert f"{project}\tcodex\t.debuffer_skills/installed-skills-codex.txt\tfull\t{repo}\t" in registry_text

    preview = run_ps([], script=RECONCILE_PS1, env=env)
    assert "Mode: preview" in preview.stdout
    assert str(project) in preview.stdout
    assert "install_debuffer.ps1" in preview.stdout
    assert "-Reconcile" in preview.stdout

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-Uninstall"], env=env)

    assert f"{project}\tcodex\t" not in registry.read_text(encoding="utf-8")


def test_install_debuffer_gui_validate_only_defaults_full() -> None:
    result = run_ps(["-ValidateOnly"], script=GUI_PS1)

    assert "图形界面校验通过。" in result.stdout
    assert "默认范围：full" in result.stdout


def test_update_debuffer_repo_ps1_dry_run(tmp_path: Path) -> None:
    repo = tmp_path / "repo"
    remote = tmp_path / "remote.git"
    subprocess.run(["git", "init", "--bare", str(remote)], check=True, capture_output=True, text=True)
    subprocess.run(["git", "clone", str(remote), str(repo)], check=True, capture_output=True, text=True)
    subprocess.run(["git", "-C", str(repo), "config", "user.name", "Test User"], check=True, capture_output=True, text=True)
    subprocess.run(["git", "-C", str(repo), "config", "user.email", "test@example.com"], check=True, capture_output=True, text=True)
    (repo / "README.md").write_text("test\n", encoding="utf-8")
    subprocess.run(["git", "-C", str(repo), "add", "README.md"], check=True, capture_output=True, text=True)
    subprocess.run(["git", "-C", str(repo), "commit", "-m", "init"], check=True, capture_output=True, text=True)
    subprocess.run(["git", "-C", str(repo), "push", "-u", "origin", "master"], check=True, capture_output=True, text=True)

    result = subprocess.run(
        [
            PS_EXE,
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            str(REPO_UPDATE_PS1),
            "-RepoRoot",
            str(repo),
            "-DryRun",
        ],
        cwd=REPO_ROOT,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=True,
    )

    assert "fetch --prune origin" in result.stdout
    assert "pull --ff-only origin master" in result.stdout


def test_install_aris_ps1_migrates_legacy_state_dir(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()
    legacy_state = project / ".aris"
    legacy_state.mkdir()
    (legacy_state / "legacy-marker.txt").write_text("keep\n", encoding="utf-8")

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo)])

    state = project / ".debuffer_skills"
    assert not legacy_state.exists()
    assert (state / "legacy-marker.txt").read_text(encoding="utf-8") == "keep\n"
    assert (state / "installed-skills-codex.txt").exists()


def test_install_aris_ps1_codex_profile_scopes_inventory(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    make_skill(repo / "skills" / "skills-codex" / "research-review", "# review\n")
    make_skill(repo / "skills" / "skills-codex" / "paper-write", "# paper\n")
    project = tmp_path / "project"
    project.mkdir()

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-Profile", "review"])

    assert junction_target(project / ".agents" / "skills" / "research-review") == (
        repo / "skills" / "skills-codex" / "research-review"
    )
    assert junction_target(project / ".agents" / "skills" / "shared-references") == (
        repo / "skills" / "skills-codex" / "shared-references"
    )
    assert not path_item_exists(project / ".agents" / "skills" / "alpha")
    assert not path_item_exists(project / ".agents" / "skills" / "paper-write")
    manifest_text = (project / ".debuffer_skills" / "installed-skills-codex.txt").read_text(encoding="utf-8")
    assert "profile\treview" in manifest_text
    assert "Profile: `review`" in (project / "AGENTS.md").read_text(encoding="utf-8")


def test_install_aris_ps1_codex_full_flat_installs_library_inventory(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    make_skill(repo / "skills" / "skills-codex-library" / "review" / "auto-review-loop", "# loop\n")
    make_skill(repo / "skills" / "skills-codex-library" / "paper" / "paper-write", "# paper\n")
    project = tmp_path / "project"
    project.mkdir()

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-Profile", "full-flat"])

    assert junction_target(project / ".agents" / "skills" / "alpha") == repo / "skills" / "skills-codex" / "alpha"
    assert junction_target(project / ".agents" / "skills" / "auto-review-loop") == (
        repo / "skills" / "skills-codex-library" / "review" / "auto-review-loop"
    )
    assert junction_target(project / ".agents" / "skills" / "paper-write") == (
        repo / "skills" / "skills-codex-library" / "paper" / "paper-write"
    )
    manifest_text = (project / ".debuffer_skills" / "installed-skills-codex.txt").read_text(encoding="utf-8")
    assert "profile\tfull-flat" in manifest_text
    assert "skills/skills-codex-library/review/auto-review-loop" in manifest_text
    assert "skills/skills-codex-library/paper/paper-write" in manifest_text


def test_install_aris_ps1_claude_uses_mainline_flat_junctions(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()

    run_ps([str(project), "-Platform", "claude", "-ArisRepo", str(repo)])

    assert (project / ".debuffer_skills" / "installed-skills.txt").exists()
    assert junction_target(project / ".claude" / "skills" / "alpha") == repo / "skills" / "alpha"
    assert junction_target(project / ".claude" / "skills" / "shared-references") == repo / "skills" / "shared-references"
    assert not (project / ".claude" / "skills" / "skills-codex").exists()
    assert not (project / ".claude" / "skills" / "aris").exists()
    claude_text = (project / "CLAUDE.md").read_text(encoding="utf-8")
    assert ".claude/skills/<skill-name>" in claude_text
    assert ".claude/skills/aris" not in claude_text


def test_install_aris_ps1_skips_upstream_junctions_outside_repo(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()
    external = tmp_path / "external-source" / "escape"
    make_skill(external, "# external escape\n")
    make_junction(repo / "skills" / "skills-codex" / "escape", external)

    result = run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo)])

    assert "skipping upstream link leading outside skill repo" in result.stderr + result.stdout
    assert not path_item_exists(project / ".agents" / "skills" / "escape")
    assert "escape" not in (project / ".debuffer_skills" / "installed-skills-codex.txt").read_text(encoding="utf-8")


def test_install_aris_ps1_skips_upstream_source_root_junction_outside_repo(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()
    codex_root = repo / "skills" / "skills-codex"
    external_root = tmp_path / "external-source"
    make_skill(external_root / "escape", "# external escape\n")
    shutil.rmtree(codex_root)
    make_junction(codex_root, external_root)

    result = run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo)], check=False)

    assert result.returncode != 0
    assert "skipping upstream link leading outside skill repo" in result.stderr + result.stdout
    assert not path_item_exists(project / ".agents" / "skills" / "escape")


def test_install_aris_ps1_replace_link_rejects_indirect_external_target(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()
    external = tmp_path / "external-source" / "beta"
    make_skill(external, "# external beta\n")
    shutil.rmtree(repo / "skills" / "skills-codex" / "beta")
    make_junction(repo / "skills" / "skills-codex" / "beta", external)
    alpha_link = project / ".agents" / "skills" / "alpha"
    make_junction(alpha_link, repo / "skills" / "skills-codex" / "beta")

    result = run_ps(
        [str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-ReplaceLink", "alpha"],
        check=False,
    )

    assert result.returncode != 0
    assert "CONFLICT" in result.stderr + result.stdout
    assert junction_target(alpha_link) == repo / "skills" / "skills-codex" / "beta"


def test_install_aris_ps1_manifest_retargeted_external_parent_junction_conflicts(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()
    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo)])

    external_root = tmp_path / "user-fork"
    make_skill(external_root / "alpha", "# user fork alpha\n")
    alias = repo / "skills" / "skills-codex" / "alias"
    make_junction(alias, external_root)
    apparent_external = alias / "alpha"
    alpha_link = project / ".agents" / "skills" / "alpha"
    remove_link(alpha_link)
    make_junction(alpha_link, apparent_external)

    result = run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-Reconcile"], check=False)

    assert result.returncode != 0
    assert "CONFLICT" in result.stderr + result.stdout
    assert junction_target(alpha_link) == apparent_external


def test_install_aris_ps1_uninstall_keeps_tools_for_other_platform_manifest(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()

    run_ps([str(project), "-Platform", "claude", "-ArisRepo", str(repo)])
    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo)])

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-Uninstall"])

    assert junction_target(project / ".debuffer_skills" / "tools") == repo / "tools"
    assert (project / ".debuffer_skills" / "installed-skills.txt").exists()
    assert not (project / ".debuffer_skills" / "installed-skills-codex.txt").exists()

    run_ps([str(project), "-Platform", "claude", "-ArisRepo", str(repo), "-Uninstall"])

    assert not path_item_exists(project / ".debuffer_skills" / "tools")


def test_install_aris_ps1_conflicts_stop_and_replace_link_relinks_junction(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()
    conflicting_real = project / ".agents" / "skills" / "alpha"
    conflicting_real.mkdir(parents=True)
    (conflicting_real / "SKILL.md").write_text("# user-owned\n", encoding="utf-8")

    result = run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo)], check=False)

    assert result.returncode != 0
    assert "CONFLICT" in result.stderr + result.stdout
    assert (conflicting_real / "SKILL.md").read_text(encoding="utf-8") == "# user-owned\n"

    shutil.rmtree(conflicting_real)
    wrong_target = repo / "skills" / "skills-codex" / "beta"
    make_junction(conflicting_real, wrong_target)

    result = run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo)], check=False)
    assert result.returncode != 0
    assert junction_target(conflicting_real) == wrong_target

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-ReplaceLink", "alpha"])
    assert junction_target(conflicting_real) == repo / "skills" / "skills-codex" / "alpha"


def test_install_aris_ps1_manifest_retargeted_external_junction_conflicts(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()
    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo)])

    alpha_link = project / ".agents" / "skills" / "alpha"
    external = tmp_path / "user-fork" / "alpha"
    make_skill(external, "# user fork alpha\n")
    remove_link(alpha_link)
    make_junction(alpha_link, external)

    result = run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-Reconcile"], check=False)
    assert result.returncode != 0
    assert "CONFLICT" in result.stderr + result.stdout
    assert junction_target(alpha_link) == external

    result = run_ps(
        [str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-Reconcile", "-ReplaceLink", "alpha"],
        check=False,
    )
    assert result.returncode != 0
    assert "CONFLICT" in result.stderr + result.stdout
    assert junction_target(alpha_link) == external


def test_install_aris_ps1_from_old_removes_nested_legacy_junction(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()
    legacy = project / ".agents" / "skills" / "aris"
    make_junction(legacy, repo / "skills" / "skills-codex")

    result = run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo)], check=False)
    assert result.returncode != 0
    assert legacy.exists()

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-FromOld"])

    assert not legacy.exists()
    assert junction_target(project / ".agents" / "skills" / "alpha") == repo / "skills" / "skills-codex" / "alpha"


def test_install_aris_ps1_clear_stale_lock(tmp_path: Path) -> None:
    repo = make_minimal_repo(tmp_path)
    project = tmp_path / "project"
    project.mkdir()
    lock_dir = project / ".debuffer_skills" / ".install-codex.lock.d"
    lock_dir.mkdir(parents=True)
    (lock_dir / "owner.pid").write_text("999999\n", encoding="utf-8")
    (lock_dir / "owner.host").write_text("stale-host\n", encoding="utf-8")

    result = run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo)], check=False)
    assert result.returncode != 0
    assert lock_dir.exists()

    run_ps([str(project), "-Platform", "codex", "-ArisRepo", str(repo), "-ClearStaleLock"])
    assert not lock_dir.exists()
    assert junction_target(project / ".agents" / "skills" / "alpha") == repo / "skills" / "skills-codex" / "alpha"
