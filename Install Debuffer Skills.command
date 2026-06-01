#!/usr/bin/env bash
# macOS double-click installer for debuffer-skills.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$SCRIPT_DIR"
INSTALLER="$REPO_ROOT/tools/install_debuffer_codex.sh"
UPDATER="$REPO_ROOT/tools/reconcile_debuffer_installs.sh"

alert() {
    local title="$1"
    local message="$2"
    osascript - "$title" "$message" <<'APPLESCRIPT' >/dev/null 2>&1 || true
on run argv
    display dialog (item 2 of argv) with title (item 1 of argv) buttons {"OK"} default button "OK"
end run
APPLESCRIPT
}

choose_folder() {
    osascript <<'APPLESCRIPT'
set selectedFolder to choose folder with prompt "Choose the research project repo to install debuffer-skills into:"
return POSIX path of selectedFolder
APPLESCRIPT
}

choose_action() {
    osascript <<'APPLESCRIPT'
set actionChoices to {"Install into one repo", "Update registered repos"}
set selectedAction to choose from list actionChoices with title "debuffer-skills" with prompt "Choose an action:" default items {"Install into one repo"} without multiple selections allowed
if selectedAction is false then error number -128
return item 1 of selectedAction
APPLESCRIPT
}

choose_profile() {
    osascript <<'APPLESCRIPT'
set profileChoices to {"full", "core-research", "paper", "review"}
set selectedProfile to choose from list profileChoices with title "debuffer-skills" with prompt "Choose install profile:" default items {"full"} without multiple selections allowed
if selectedProfile is false then error number -128
return item 1 of selectedProfile
APPLESCRIPT
}

choose_options() {
    osascript <<'APPLESCRIPT'
set optionChoices to {"Reconcile existing install", "Dry run only"}
set selectedOptions to choose from list optionChoices with title "debuffer-skills" with prompt "Optional install flags:" with multiple selections allowed
if selectedOptions is false then return ""
set AppleScript's text item delimiters to "|"
set resultText to selectedOptions as text
set AppleScript's text item delimiters to ""
return resultText
APPLESCRIPT
}

confirm_install() {
    local project="$1"
    local profile="$2"
    local options="$3"
    local message
    message="$(printf 'Project: %s\nProfile: %s\nOptions: %s\n\nInstall project-local debuffer-skills?' "$project" "$profile" "${options:-none}")"
    osascript - "$message" <<'APPLESCRIPT' >/dev/null
on run argv
    display dialog (item 1 of argv) with title "debuffer-skills" buttons {"Cancel", "Install"} default button "Install" cancel button "Cancel"
end run
APPLESCRIPT
}

confirm_update() {
    osascript <<'APPLESCRIPT' >/dev/null
display dialog "Update every project registered by this debuffer-skills checkout?" with title "debuffer-skills" buttons {"Cancel", "Update"} default button "Update" cancel button "Cancel"
APPLESCRIPT
}

if [[ ! -f "$INSTALLER" || ! -f "$UPDATER" || ! -d "$REPO_ROOT/skills/skills-codex" ]]; then
    echo "This launcher must be run from the root of a debuffer-skills repo." >&2
    alert "debuffer-skills" "This launcher must be run from the root of a debuffer-skills repo."
    exit 1
fi

if ! command -v osascript >/dev/null 2>&1; then
    echo "osascript is required for the macOS GUI launcher." >&2
    exit 1
fi

echo "debuffer-skills macOS installer"
echo "Skill repo: $REPO_ROOT"
echo

ACTION="$(choose_action)" || exit 0

if [[ "$ACTION" == "Update registered repos" ]]; then
    confirm_update || exit 0
    echo "Running registered project update..."
    echo
    bash "$UPDATER" --apply
    STATUS=$?
    echo
    if [[ $STATUS -eq 0 ]]; then
        echo "Update completed."
        alert "debuffer-skills" "Update completed."
    else
        echo "Update failed with exit code $STATUS." >&2
        alert "debuffer-skills" "Update failed with exit code $STATUS. Check the Terminal output."
    fi
    echo
    read -r -p "Press Enter to close this window..."
    exit "$STATUS"
fi

PROJECT_PATH="$(choose_folder)" || exit 0
PROFILE="$(choose_profile)" || exit 0
OPTIONS="$(choose_options)" || OPTIONS=""

confirm_install "$PROJECT_PATH" "$PROFILE" "$OPTIONS" || exit 0

ARGS=("$PROJECT_PATH" "--repo" "$REPO_ROOT" "--profile" "$PROFILE")
case "|$OPTIONS|" in
    *"|Reconcile existing install|"*) ARGS+=("--reconcile") ;;
esac
case "|$OPTIONS|" in
    *"|Dry run only|"*) ARGS+=("--dry-run") ;;
esac

echo "Project: $PROJECT_PATH"
echo "Profile: $PROFILE"
echo "Options: ${OPTIONS:-none}"
echo
echo "Running installer..."
echo

bash "$INSTALLER" "${ARGS[@]}"
STATUS=$?

echo
if [[ $STATUS -eq 0 ]]; then
    echo "Install completed."
    alert "debuffer-skills" "Install completed."
else
    echo "Install failed with exit code $STATUS." >&2
    alert "debuffer-skills" "Install failed with exit code $STATUS. Check the Terminal output."
fi

echo
read -r -p "Press Enter to close this window..."
exit "$STATUS"
