#!/usr/bin/env bash
# Portable project bootstrap for debuffer-skills.
# Copy this file into a project repo and run it from there, or run it with
# --project /path/to/project. It discovers a central debuffer-skills clone and
# delegates to tools/install_debuffer_codex.sh.

set -euo pipefail

PROJECT_PATH=""
SKILL_REPO=""
PROFILE="core-research"
PLATFORM="codex"
RECONCILE=false
DRY_RUN=false
CLONE_IF_MISSING=false
REPO_URL="https://github.com/Yulivu/debuffer-skills.git"
REPO_DESTINATION=""

usage() {
    sed -n '2,80p' "$0" | sed 's/^# \?//'
    cat <<'EOF'

Options:
  --project PATH          Target project. Default: this script's directory,
                          unless the script is running from inside the skill repo.
  --repo PATH             Central debuffer-skills repo.
  --profile NAME          core-research, paper, review, or full.
  --platform NAME         codex is the default. Other platforms use install_debuffer.ps1.
  --reconcile             Reconcile an existing install.
  --dry-run               Show installer plan only.
  --clone-if-missing      Clone the skill repo if discovery fails.
  --repo-url URL          Git URL used with --clone-if-missing.
  --repo-destination PATH Clone destination. Default: ~/.codex/debuffer-skills.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project) PROJECT_PATH="${2:?--project requires PATH}"; shift 2 ;;
        --repo) SKILL_REPO="${2:?--repo requires PATH}"; shift 2 ;;
        --profile) PROFILE="${2:?--profile requires NAME}"; shift 2 ;;
        --platform) PLATFORM="${2:?--platform requires NAME}"; shift 2 ;;
        --reconcile) RECONCILE=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        --clone-if-missing) CLONE_IF_MISSING=true; shift ;;
        --repo-url) REPO_URL="${2:?--repo-url requires URL}"; shift 2 ;;
        --repo-destination) REPO_DESTINATION="${2:?--repo-destination requires PATH}"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

case "$PROFILE" in
    core-research|paper|review|full) ;;
    *) echo "unknown profile: $PROFILE" >&2; exit 2 ;;
esac

abs_path() { (cd "$1" 2>/dev/null && pwd) || return 1; }

is_debuffer_repo() {
    local p="${1:-}"
    [[ -n "$p" ]] || return 1
    [[ -d "$p/skills" && -d "$p/skills/skills-codex" && -f "$p/tools/install_debuffer_codex.sh" ]]
}

add_candidate() {
    local p="${1:-}"
    [[ -n "$p" ]] || return 0
    CANDIDATES+=("$p")
}

add_tree_candidates() {
    local start="${1:-}"
    [[ -n "$start" && -e "$start" ]] || return 0
    local dir
    if [[ -d "$start" ]]; then dir="$(cd "$start" && pwd)"
    else dir="$(cd "$(dirname "$start")" && pwd)"
    fi
    while [[ -n "$dir" && "$dir" != "/" ]]; do
        add_candidate "$dir"
        add_candidate "$dir/debuffer-skills"
        add_candidate "$(dirname "$dir")/debuffer-skills"
        dir="$(dirname "$dir")"
    done
}

find_repo() {
    CANDIDATES=()
    add_candidate "$SKILL_REPO"
    add_candidate "${DEBUFFER_SKILLS_REPO:-}"
    add_candidate "${SKILL_REPO:-}"
    add_candidate "${ARIS_REPO:-}"
    add_tree_candidates "$SCRIPT_DIR"
    add_tree_candidates "$(pwd)"
    [[ -n "$PROJECT_ROOT" ]] && add_tree_candidates "$PROJECT_ROOT"
    add_candidate "$HOME/debuffer-skills"
    add_candidate "$HOME/Desktop/debuffer-skills"
    add_candidate "$HOME/.codex/debuffer-skills"
    add_candidate "$HOME/.claude/debuffer-skills"

    local candidate canonical seen_key
    declare -A SEEN=()
    for candidate in "${CANDIDATES[@]}"; do
        [[ -n "$candidate" ]] || continue
        canonical="$(abs_path "$candidate" 2>/dev/null || true)"
        [[ -n "$canonical" ]] || continue
        seen_key="$canonical"
        [[ -z "${SEEN[$seen_key]:-}" ]] || continue
        SEEN[$seen_key]=1
        if is_debuffer_repo "$canonical"; then
            echo "$canonical"
            return 0
        fi
    done

    if $CLONE_IF_MISSING; then
        local dest="$REPO_DESTINATION"
        [[ -n "$dest" ]] || dest="$HOME/.codex/debuffer-skills"
        if [[ ! -e "$dest" ]]; then
            mkdir -p "$(dirname "$dest")"
            git clone "$REPO_URL" "$dest"
        fi
        canonical="$(abs_path "$dest" 2>/dev/null || true)"
        if is_debuffer_repo "$canonical"; then
            echo "$canonical"
            return 0
        fi
    fi

    cat >&2 <<'EOF'
Cannot find a debuffer-skills repo.

Use one of:
  --repo /path/to/debuffer-skills
  DEBUFFER_SKILLS_REPO=/path/to/debuffer-skills
  a sibling/user clone named debuffer-skills
  --clone-if-missing [--repo-url <git-url>]
EOF
    return 1
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ -n "$PROJECT_PATH" ]]; then
    PROJECT_ROOT="$(abs_path "$PROJECT_PATH")" || { echo "project path not found: $PROJECT_PATH" >&2; exit 1; }
else
    # If the script is running from inside the skill repo itself, default to
    # the current working directory. If copied into a project, default to the
    # copied script's directory.
    PROJECT_ROOT="$SCRIPT_DIR"
fi

REPO_ROOT="$(find_repo)"

if [[ -z "$PROJECT_PATH" && "$SCRIPT_DIR" == "$REPO_ROOT"* ]]; then
    PROJECT_ROOT="$(pwd)"
fi

PROJECT_ROOT="$(abs_path "$PROJECT_ROOT")"
if [[ "$PROJECT_ROOT" == "$REPO_ROOT" ]]; then
    echo "target project is the debuffer-skills repo itself; pass --project or copy this script into a project." >&2
    exit 1
fi

if [[ "$PLATFORM" != "codex" ]]; then
    echo "bash bootstrap currently supports --platform codex. Use tools/use_debuffer_skills.ps1 for other platforms." >&2
    exit 2
fi

ARGS=("$PROJECT_ROOT" "--repo" "$REPO_ROOT" "--profile" "$PROFILE")
$RECONCILE && ARGS+=("--reconcile")
$DRY_RUN && ARGS+=("--dry-run")

echo
echo "debuffer-skills project bootstrap"
echo "  Project: $PROJECT_ROOT"
echo "  Repo:    $REPO_ROOT"
echo "  Profile: $PROFILE"
echo "  Platform: $PLATFORM"
echo

exec bash "$REPO_ROOT/tools/install_debuffer_codex.sh" "${ARGS[@]}"
