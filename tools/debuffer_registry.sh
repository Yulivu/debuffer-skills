#!/usr/bin/env bash
# Local registry helpers for project installs managed by this skill repo.

debuffer_registry_path() {
    local repo_root="$1"
    if [[ -n "${DEBUFFER_REGISTRY_PATH:-}" ]]; then
        printf "%s\n" "$DEBUFFER_REGISTRY_PATH"
    else
        printf "%s\n" "$repo_root/.debuffer_registry/installed-projects.tsv"
    fi
}

debuffer_registry_has_unsafe_tsv_value() {
    case "$1" in
        *$'\t'*|*$'\n'*|*$'\r'*) return 0 ;;
        *) return 1 ;;
    esac
}

debuffer_registry_write_header() {
    printf "# debuffer managed installs registry v1\n"
    printf "# project_root<TAB>platform<TAB>manifest<TAB>profile<TAB>repo_root<TAB>last_seen_utc\n"
}

debuffer_registry_upsert() {
    local repo_root="$1" project_root="$2" platform="$3" manifest_rel="$4" profile="$5"
    [[ "${DEBUFFER_REGISTRY_DISABLE:-}" == "1" ]] && return 0
    local value
    for value in "$repo_root" "$project_root" "$platform" "$manifest_rel" "$profile"; do
        if debuffer_registry_has_unsafe_tsv_value "$value"; then
            echo "warning: skipping install registry update; path contains a tab or newline" >&2
            return 0
        fi
    done

    local registry registry_dir tmp now
    registry="$(debuffer_registry_path "$repo_root")"
    registry_dir="$(dirname "$registry")"
    mkdir -p "$registry_dir" 2>/dev/null || {
        echo "warning: cannot create install registry directory: $registry_dir" >&2
        return 0
    }
    now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    tmp="$registry.tmp.$$"
    {
        debuffer_registry_write_header
        if [[ -f "$registry" ]]; then
            awk -F'\t' -v p="$project_root" -v platform="$platform" -v manifest="$manifest_rel" '
                BEGIN { OFS=FS }
                /^#/ || NF < 6 { next }
                !($1 == p && $2 == platform && $3 == manifest) { print $0 }
            ' "$registry"
        fi
        printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$project_root" "$platform" "$manifest_rel" "$profile" "$repo_root" "$now"
    } > "$tmp" && mv -f "$tmp" "$registry" || {
        rm -f "$tmp"
        echo "warning: cannot update install registry: $registry" >&2
        return 0
    }
}

debuffer_registry_remove() {
    local repo_root="$1" project_root="$2" platform="$3" manifest_rel="$4"
    [[ "${DEBUFFER_REGISTRY_DISABLE:-}" == "1" ]] && return 0
    local registry tmp
    registry="$(debuffer_registry_path "$repo_root")"
    [[ -f "$registry" ]] || return 0
    tmp="$registry.tmp.$$"
    {
        debuffer_registry_write_header
        awk -F'\t' -v p="$project_root" -v platform="$platform" -v manifest="$manifest_rel" '
            BEGIN { OFS=FS }
            /^#/ || NF < 6 { next }
            !($1 == p && $2 == platform && $3 == manifest) { print $0 }
        ' "$registry"
    } > "$tmp" && mv -f "$tmp" "$registry" || {
        rm -f "$tmp"
        echo "warning: cannot update install registry: $registry" >&2
        return 0
    }
}
