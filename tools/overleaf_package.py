#!/usr/bin/env python3
"""Build an Overleaf-uploadable zip from a local LaTeX paper tree."""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


TEX_EXTENSIONS = {".tex"}
GRAPHIC_EXTENSIONS = [".pdf", ".png", ".jpg", ".jpeg", ".eps", ".svg"]
STYLE_EXTENSIONS = {".bib", ".bst", ".cls", ".sty"}
EXCLUDED_DIRS = {
    ".git",
    ".github",
    ".debuffer_skills",
    ".aris",
    ".pytest_cache",
    "__pycache__",
    "dist",
    "paper-overleaf",
    ".idea",
    ".vscode",
}
EXCLUDED_SUFFIXES = {
    ".aux",
    ".bcf",
    ".blg",
    ".fdb_latexmk",
    ".fls",
    ".lof",
    ".log",
    ".lot",
    ".nav",
    ".out",
    ".run.xml",
    ".snm",
    ".synctex.gz",
    ".toc",
    ".vrb",
    ".xdv",
}

INPUT_RE = re.compile(r"\\(?:input|include|subfile)\{([^}]+)\}")
GRAPHICS_RE = re.compile(r"\\includegraphics(?:\[[^\]]*\])?\{([^}]+)\}")
BIB_RE = re.compile(r"\\bibliography\{([^}]+)\}")
ADDBIB_RE = re.compile(r"\\addbibresource(?:\[[^\]]*\])?\{([^}]+)\}")
DOCCLASS_RE = re.compile(r"\\documentclass(?:\[[^\]]*\])?\{([^}]+)\}")
USEPACKAGE_RE = re.compile(r"\\usepackage(?:\[[^\]]*\])?\{([^}]+)\}")


def iter_project_files(root: Path) -> list[Path]:
    files: list[Path] = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if any(part in EXCLUDED_DIRS for part in path.relative_to(root).parts):
            continue
        if any(str(path.name).endswith(suffix) for suffix in EXCLUDED_SUFFIXES):
            continue
        files.append(path)
    return sorted(files)


def pick_main_tex(root: Path) -> Path:
    tex_files = [path for path in iter_project_files(root) if path.suffix.lower() in TEX_EXTENSIONS]
    if not tex_files:
        raise SystemExit(f"no .tex file found under {root}")

    preferred = root / "main.tex"
    if preferred.exists():
        return preferred

    docclass_files = []
    for path in tex_files:
        text = path.read_text(encoding="utf-8", errors="ignore")
        if "\\documentclass" in text:
            docclass_files.append(path)
    if len(docclass_files) == 1:
        return docclass_files[0]
    if docclass_files:
        for path in docclass_files:
            if path.name.lower() in {"paper.tex", "manuscript.tex"}:
                return path
        return docclass_files[0]
    return tex_files[0]


def resolve_candidate(base_dir: Path, raw: str, suffixes: list[str]) -> Path | None:
    raw = raw.strip()
    if not raw:
        return None
    candidate = Path(raw)
    if candidate.is_absolute():
        return candidate
    if candidate.suffix:
        probe = (base_dir / candidate).resolve()
        return probe if probe.exists() else None
    for suffix in suffixes:
        probe = (base_dir / f"{raw}{suffix}").resolve()
        if probe.exists():
            return probe
    probe = (base_dir / raw).resolve()
    return probe if probe.exists() else None


def normalize_rel(path: Path, root: Path) -> str:
    return path.relative_to(root).as_posix()


def collect_from_tex(
    tex_path: Path,
    root: Path,
    selected: set[Path],
    visited_tex: set[Path],
    warnings: list[str],
) -> None:
    tex_path = tex_path.resolve()
    if tex_path in visited_tex:
        return
    visited_tex.add(tex_path)
    selected.add(tex_path)
    text = tex_path.read_text(encoding="utf-8", errors="ignore")
    base_dir = tex_path.parent

    for raw in INPUT_RE.findall(text):
        resolved = resolve_candidate(base_dir, raw, [".tex"])
        if resolved is None:
            warnings.append(f"missing input/include target: {raw} (from {normalize_rel(tex_path, root)})")
            continue
        if not resolved.is_relative_to(root):
            warnings.append(f"input/include points outside root: {raw} (from {normalize_rel(tex_path, root)})")
            continue
        collect_from_tex(resolved, root, selected, visited_tex, warnings)

    for raw in GRAPHICS_RE.findall(text):
        if Path(raw).is_absolute():
            warnings.append(f"absolute graphic path: {raw} (from {normalize_rel(tex_path, root)})")
            continue
        resolved = resolve_candidate(base_dir, raw, GRAPHIC_EXTENSIONS)
        if resolved is None:
            warnings.append(f"missing graphic: {raw} (from {normalize_rel(tex_path, root)})")
            continue
        if not resolved.is_relative_to(root):
            warnings.append(f"graphic points outside root: {raw} (from {normalize_rel(tex_path, root)})")
            continue
        selected.add(resolved)

    for block in BIB_RE.findall(text):
        for raw in [part.strip() for part in block.split(",") if part.strip()]:
            resolved = resolve_candidate(base_dir, raw, [".bib"])
            if resolved is None:
                warnings.append(f"missing bibliography file: {raw} (from {normalize_rel(tex_path, root)})")
                continue
            if not resolved.is_relative_to(root):
                warnings.append(f"bibliography points outside root: {raw} (from {normalize_rel(tex_path, root)})")
                continue
            selected.add(resolved)

    for raw in ADDBIB_RE.findall(text):
        resolved = resolve_candidate(base_dir, raw, [".bib"])
        if resolved is None:
            warnings.append(f"missing biblatex resource: {raw} (from {normalize_rel(tex_path, root)})")
            continue
        if not resolved.is_relative_to(root):
            warnings.append(f"biblatex resource points outside root: {raw} (from {normalize_rel(tex_path, root)})")
            continue
        selected.add(resolved)

    for block in DOCCLASS_RE.findall(text):
        for raw in [part.strip() for part in block.split(",") if part.strip()]:
            resolved = resolve_candidate(base_dir, raw, [".cls"])
            if resolved is not None and resolved.is_relative_to(root):
                selected.add(resolved)

    for block in USEPACKAGE_RE.findall(text):
        for raw in [part.strip() for part in block.split(",") if part.strip()]:
            resolved = resolve_candidate(base_dir, raw, [".sty"])
            if resolved is not None and resolved.is_relative_to(root):
                selected.add(resolved)


def build_manifest(
    *,
    root: Path,
    main_tex: Path,
    files: list[Path],
    warnings: list[str],
    zip_path: Path,
) -> dict[str, object]:
    return {
        "created_at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "root": str(root),
        "main_tex": normalize_rel(main_tex, root),
        "zip_path": str(zip_path),
        "file_count": len(files),
        "files": [normalize_rel(path, root) for path in files],
        "warnings": warnings,
        "status": "warning" if warnings else "ok",
    }


def write_manifest_text(path: Path, manifest: dict[str, object]) -> None:
    lines = [
        f"created_at: {manifest['created_at']}",
        f"root: {manifest['root']}",
        f"main_tex: {manifest['main_tex']}",
        f"zip_path: {manifest['zip_path']}",
        f"file_count: {manifest['file_count']}",
        f"status: {manifest['status']}",
        "",
        "[files]",
    ]
    lines.extend(f"- {item}" for item in manifest["files"])
    lines.append("")
    lines.append("[warnings]")
    warnings = manifest["warnings"]
    if warnings:
        lines.extend(f"- {item}" for item in warnings)
    else:
        lines.append("- none")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def make_archive_name(main_tex: Path, explicit_name: str | None) -> str:
    if explicit_name:
        return explicit_name[:-4] if explicit_name.endswith(".zip") else explicit_name
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    stem = re.sub(r"[^A-Za-z0-9._-]+", "_", main_tex.stem).strip("_") or "paper"
    return f"overleaf_package_{stem}_{stamp}"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", nargs="?", default="paper", help="paper root directory or main tex path")
    parser.add_argument("--output-dir", default="dist", help="directory for zip and manifests")
    parser.add_argument("--name", default=None, help="archive base name, with or without .zip")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    source = Path(args.source).resolve()
    if not source.exists():
        print(f"error: source does not exist: {source}", file=sys.stderr)
        return 1

    if source.is_file():
        if source.suffix.lower() not in TEX_EXTENSIONS:
            print(f"error: source file must be .tex: {source}", file=sys.stderr)
            return 1
        root = source.parent
        main_tex = source
    else:
        root = source
        main_tex = pick_main_tex(root)

    output_dir = Path(args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    selected: set[Path] = set()
    warnings: list[str] = []
    visited_tex: set[Path] = set()

    collect_from_tex(main_tex, root, selected, visited_tex, warnings)
    for path in iter_project_files(root):
        if path.suffix.lower() in STYLE_EXTENSIONS:
            selected.add(path.resolve())

    files = sorted(selected, key=lambda path: normalize_rel(path, root))
    if not files:
        print(f"error: no files selected from {root}", file=sys.stderr)
        return 1

    archive_name = make_archive_name(main_tex, args.name)
    zip_path = output_dir / f"{archive_name}.zip"
    with ZipFile(zip_path, "w", compression=ZIP_DEFLATED) as zf:
        for path in files:
            zf.write(path, arcname=normalize_rel(path, root))

    manifest = build_manifest(root=root, main_tex=main_tex, files=files, warnings=warnings, zip_path=zip_path)
    manifest_json_path = output_dir / f"{archive_name}.manifest.json"
    manifest_txt_path = output_dir / f"{archive_name}.manifest.txt"
    manifest_json_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    write_manifest_text(manifest_txt_path, manifest)

    print(f"zip: {zip_path}")
    print(f"manifest: {manifest_txt_path}")
    print(f"status: {manifest['status']}")
    if warnings:
        print("warnings:")
        for item in warnings:
            print(f"- {item}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
