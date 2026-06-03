#!/usr/bin/env bash
# Update this debuffer-skills checkout from GitHub with a fast-forward pull.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT_OVERRIDE=""
DRY_RUN=false

usage() {
    cat <<'EOF'
Usage:
  bash tools/update_debuffer_repo.sh [--dry-run] [--repo-root <path>]

Options:
  --dry-run   Print what would run without modifying the checkout.
  --repo-root Override the debuffer-skills checkout to update.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --repo-root) REPO_ROOT_OVERRIDE="${2:?--repo-root requires path}"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

die() { echo "error: $*" >&2; exit 1; }
run() {
    if $DRY_RUN; then
        printf "+ %q" "$@"
        printf "\n"
        return 0
    fi
    "$@"
}

command -v git >/dev/null 2>&1 || die "git not found in PATH"
if [[ -n "$REPO_ROOT_OVERRIDE" ]]; then
    REPO_ROOT="$(cd "$REPO_ROOT_OVERRIDE" && pwd)"
fi
git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git checkout: $REPO_ROOT"

branch="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
[[ "$branch" != "HEAD" ]] || die "detached HEAD is not supported; switch to a branch first"

if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
    die "working tree is not clean; commit or stash local changes before GitHub update"
fi

remote_url="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)"
[[ -n "$remote_url" ]] || die "git remote 'origin' is not configured"

echo "Repo: $REPO_ROOT"
echo "Remote: $remote_url"
echo "Branch: $branch"

run git -C "$REPO_ROOT" fetch --prune origin
run git -C "$REPO_ROOT" pull --ff-only origin "$branch"

if ! $DRY_RUN; then
    echo "Updated to: $(git -C "$REPO_ROOT" rev-parse --short HEAD)"
fi
