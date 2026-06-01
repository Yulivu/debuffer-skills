#!/usr/bin/env bash
# Reconcile every project recorded in this debuffer-skills checkout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REGISTRY_PATH="${DEBUFFER_REGISTRY_PATH:-$REPO_ROOT/.debuffer_registry/installed-projects.tsv}"
APPLY=false
LIST_ONLY=false
PRUNE=false
DISCOVER_ROOTS=()

usage() {
    cat <<'EOF'
Usage:
  bash tools/reconcile_debuffer_installs.sh [--apply] [--list] [--prune]
  bash tools/reconcile_debuffer_installs.sh --discover <root> [--apply]

Options:
  --apply             Actually run reconcile. Without it, only prints commands.
  --list              List registry entries and exit.
  --discover <root>   Scan existing project manifests under root and register them.
  --prune             With --apply, remove entries whose project or manifest is missing.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --apply) APPLY=true; shift ;;
        --list) LIST_ONLY=true; shift ;;
        --prune) PRUNE=true; shift ;;
        --discover) DISCOVER_ROOTS+=("${2:?--discover requires root}"); shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

die() { echo "error: $*" >&2; exit 1; }
warn() { echo "warning: $*" >&2; }

if [[ -f "$SCRIPT_DIR/debuffer_registry.sh" ]]; then
    # shellcheck source=tools/debuffer_registry.sh
    source "$SCRIPT_DIR/debuffer_registry.sh"
fi

manifest_value() {
    local manifest="$1" key="$2"
    awk -F'\t' -v k="$key" '$1 == k {print $2; exit}' "$manifest"
}

detect_platform_from_manifest() {
    case "$(basename "$1")" in
        installed-skills-codex.txt) echo "codex" ;;
        installed-skills-copilot.txt) echo "copilot" ;;
        installed-skills.txt) echo "claude" ;;
        *) echo "" ;;
    esac
}

register_manifest() {
    local manifest="$1"
    local project_root platform profile repo_root manifest_rel
    project_root="$(manifest_value "$manifest" "project_root")"
    [[ -n "$project_root" ]] || project_root="$(cd "$(dirname "$manifest")/.." && pwd)"
    repo_root="$(manifest_value "$manifest" "repo_root")"
    [[ -n "$repo_root" ]] || repo_root="$REPO_ROOT"
    profile="$(manifest_value "$manifest" "profile")"
    [[ -n "$profile" ]] || profile="full"
    platform="$(manifest_value "$manifest" "platform")"
    [[ -n "$platform" ]] || platform="$(detect_platform_from_manifest "$manifest")"
    [[ -n "$platform" ]] || return 0
    manifest_rel=".debuffer_skills/$(basename "$manifest")"
    if [[ -n "${repo_root:-}" && -d "$repo_root" && "$(cd "$repo_root" && pwd)" != "$REPO_ROOT" ]]; then
        warn "manifest belongs to another skill repo, registering current checkout anyway: $manifest"
    fi
    if declare -F debuffer_registry_upsert >/dev/null 2>&1; then
        debuffer_registry_upsert "$REPO_ROOT" "$project_root" "$platform" "$manifest_rel" "$profile"
    fi
}

for root in "${DISCOVER_ROOTS[@]}"; do
    [[ -d "$root" ]] || die "--discover root does not exist: $root"
    while IFS= read -r -d '' manifest; do
        register_manifest "$manifest"
    done < <(
        find "$root" \
            \( -path '*/.git/*' -o -path '*/node_modules/*' -o -path '*/.venv/*' -o -path '*/venv/*' \) -prune \
            -o -path '*/.debuffer_skills/installed-skills*.txt' -type f -print0 2>/dev/null
    )
done

if [[ ! -f "$REGISTRY_PATH" ]]; then
    cat <<EOF
No install registry found:
  $REGISTRY_PATH

Future installs will register automatically. For older installs, run:
  bash tools/reconcile_debuffer_installs.sh --discover /path/to/projects
EOF
    exit 0
fi

ENTRIES=()
while IFS= read -r entry; do
    ENTRIES+=("$entry")
done < <(awk -F'\t' '!/^#/ && NF >= 6 {print}' "$REGISTRY_PATH")
if [[ ${#ENTRIES[@]} -eq 0 ]]; then
    echo "Install registry is empty: $REGISTRY_PATH"
    exit 0
fi

echo "Registry: $REGISTRY_PATH"
echo "Mode: $($APPLY && echo apply || echo preview)"
echo ""

updated_tmp="$(mktemp -t debuffer-registry-prune.XXXX)"
{
    printf "# debuffer managed installs registry v1\n"
    printf "# project_root<TAB>platform<TAB>manifest<TAB>profile<TAB>repo_root<TAB>last_seen_utc\n"
} > "$updated_tmp"

seen=0
skipped=0
failed=0

for entry in "${ENTRIES[@]}"; do
    IFS=$'\t' read -r project_root platform manifest_rel profile repo_root last_seen <<<"$entry"
    manifest="$project_root/$manifest_rel"
    command=()
    case "$platform" in
        codex)
            command=(bash "$REPO_ROOT/tools/install_debuffer_codex.sh" "$project_root" --repo "$REPO_ROOT" --profile "$profile" --reconcile --quiet)
            if [[ -f "$manifest" ]]; then
                packages="$(manifest_value "$manifest" "packages")"
                case ",$packages," in
                    *,skills-codex-claude-review,*) command+=(--with-claude-review-overlay) ;;
                esac
                case ",$packages," in
                    *,skills-codex-gemini-review,*) command+=(--with-gemini-review-overlay) ;;
                esac
            fi
            ;;
        claude)
            command=(bash "$REPO_ROOT/tools/install_aris.sh" "$project_root" --repo "$REPO_ROOT" --reconcile --quiet)
            ;;
        copilot)
            command=(bash "$REPO_ROOT/tools/install_aris_copilot.sh" "$project_root" --repo "$REPO_ROOT" --reconcile --quiet)
            ;;
        *)
            warn "unknown platform '$platform' for $project_root"
            skipped=$((skipped + 1))
            continue
            ;;
    esac

    if [[ ! -d "$project_root" || ! -f "$manifest" ]]; then
        warn "missing project or manifest: $project_root ($manifest_rel)"
        skipped=$((skipped + 1))
        if $PRUNE && $APPLY && declare -F debuffer_registry_remove >/dev/null 2>&1; then
            debuffer_registry_remove "$REPO_ROOT" "$project_root" "$platform" "$manifest_rel"
        elif ! $PRUNE; then
            printf "%s\n" "$entry" >> "$updated_tmp"
        fi
        continue
    fi

    printf "%s [%s, %s]\n" "$project_root" "$platform" "$profile"
    if $LIST_ONLY || ! $APPLY; then
        printf "  %q" "${command[@]}"
        printf "\n"
        printf "%s\n" "$entry" >> "$updated_tmp"
        seen=$((seen + 1))
        continue
    fi

    if "${command[@]}"; then
        seen=$((seen + 1))
        if [[ -f "$REGISTRY_PATH" ]]; then
            # Installer already refreshed last_seen. Keep this temp file as a
            # fallback only for entries not rewritten in this process.
            :
        fi
    else
        failed=$((failed + 1))
        printf "%s\n" "$entry" >> "$updated_tmp"
    fi
done

rm -f "$updated_tmp"

echo ""
echo "Done. Seen: $seen, skipped: $skipped, failed: $failed"
if ! $APPLY && ! $LIST_ONLY; then
    echo "Preview only. Re-run with --apply to reconcile all listed projects."
fi

[[ $failed -eq 0 ]]
