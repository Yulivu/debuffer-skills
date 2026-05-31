#!/usr/bin/env bash
# Public Codex installer entry for debuffer-skills.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo)
            ARGS+=("--repo" "${2:?--repo requires PATH}")
            shift 2
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

exec bash "$SCRIPT_DIR/install_aris_codex.sh" "${ARGS[@]}"
