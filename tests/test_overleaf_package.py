from __future__ import annotations

import json
import subprocess
from pathlib import Path
from zipfile import ZipFile


REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPT = REPO_ROOT / "tools" / "overleaf_package.py"


def run(cmd: list[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, cwd=cwd, text=True, capture_output=True, check=True)


def test_overleaf_package_builds_archive_and_manifests(tmp_path: Path) -> None:
    paper = tmp_path / "paper"
    (paper / "sec").mkdir(parents=True)
    (paper / "figures").mkdir()
    (paper / "main.tex").write_text(
        "\\documentclass{article}\n"
        "\\usepackage{mystyle}\n"
        "\\begin{document}\n"
        "\\input{sec/intro}\n"
        "\\includegraphics{figures/plot}\n"
        "\\bibliography{refs}\n"
        "\\end{document}\n",
        encoding="utf-8",
    )
    (paper / "sec" / "intro.tex").write_text("Intro\n", encoding="utf-8")
    (paper / "figures" / "plot.pdf").write_bytes(b"%PDF-1.4\n")
    (paper / "refs.bib").write_text("@article{a,title={t}}\n", encoding="utf-8")
    (paper / "mystyle.sty").write_text("% style\n", encoding="utf-8")
    (paper / "main.aux").write_text("junk\n", encoding="utf-8")

    result = run(["python", str(SCRIPT), str(paper), "--output-dir", str(tmp_path / "dist"), "--name", "pkg"], cwd=tmp_path)

    assert "status: ok" in result.stdout
    zip_path = tmp_path / "dist" / "pkg.zip"
    manifest_json = tmp_path / "dist" / "pkg.manifest.json"
    manifest_txt = tmp_path / "dist" / "pkg.manifest.txt"
    assert zip_path.exists()
    assert manifest_json.exists()
    assert manifest_txt.exists()

    with ZipFile(zip_path) as zf:
        names = set(zf.namelist())
    assert "main.tex" in names
    assert "sec/intro.tex" in names
    assert "figures/plot.pdf" in names
    assert "refs.bib" in names
    assert "mystyle.sty" in names
    assert "main.aux" not in names

    manifest = json.loads(manifest_json.read_text(encoding="utf-8"))
    assert manifest["main_tex"] == "main.tex"
    assert manifest["status"] == "ok"
    assert manifest["warnings"] == []


def test_overleaf_package_reports_missing_graphics_warning(tmp_path: Path) -> None:
    paper = tmp_path / "paper"
    paper.mkdir()
    (paper / "main.tex").write_text(
        "\\documentclass{article}\n"
        "\\begin{document}\n"
        "\\includegraphics{figures/missing_plot}\n"
        "\\end{document}\n",
        encoding="utf-8",
    )

    result = run(["python", str(SCRIPT), str(paper), "--output-dir", str(tmp_path / "dist"), "--name", "warn"], cwd=tmp_path)

    assert "status: warning" in result.stdout
    manifest = json.loads((tmp_path / "dist" / "warn.manifest.json").read_text(encoding="utf-8"))
    assert manifest["status"] == "warning"
    assert any("missing graphic" in item for item in manifest["warnings"])
