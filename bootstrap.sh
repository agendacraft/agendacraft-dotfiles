#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_URL="https://github.com/agendacraft/agendacraft-dotfiles.git"
DEFAULT_REPO_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/agendacraft-dotfiles"
STARSHIP_VERSION="v1.25.1"
STARSHIP_INSTALLER_COMMIT="8758daa7767d4e73874330b1e262fca66a7ffd30"
STARSHIP_INSTALLER_SHA256="52c64f14a558034ebeb1907ea9364e802b32474576fd3e68265f73bc33cc8fbb"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

if [[ -d "$SCRIPT_DIR/.git" || -f "$SCRIPT_DIR/.git" ]]; then
  REPO_DIR=$SCRIPT_DIR
else
  REPO_DIR=${AGENDA_DOTFILES_DIR:-$DEFAULT_REPO_DIR}
fi

if ! command -v apt-get >/dev/null 2>&1; then
  printf 'bootstrap.sh currently supports Ubuntu/Debian hosts with apt-get.\n' >&2
  exit 1
fi

SUDO=()
if (( EUID != 0 )); then
  if ! command -v sudo >/dev/null 2>&1; then
    printf 'Run as root or install sudo first.\n' >&2
    exit 1
  fi
  SUDO=(sudo)
fi

packages=()
command -v git >/dev/null 2>&1 || packages+=(git)
command -v tmux >/dev/null 2>&1 || packages+=(tmux)
command -v curl >/dev/null 2>&1 || packages+=(curl)
[[ -s /etc/ssl/certs/ca-certificates.crt ]] || packages+=(ca-certificates)

if (( ${#packages[@]} > 0 )); then
  "${SUDO[@]}" apt-get update
  "${SUDO[@]}" apt-get install -y --no-install-recommends "${packages[@]}"
fi

if ! command -v starship >/dev/null 2>&1; then
  installer=$(mktemp)
  cleanup() { rm -f -- "$installer"; }
  trap cleanup EXIT
  installer_url="https://raw.githubusercontent.com/starship/starship/${STARSHIP_INSTALLER_COMMIT}/install/install.sh"
  curl --fail --silent --show-error --location \
    --proto '=https' --proto-redir '=https' \
    "$installer_url" --output "$installer"
  if ! printf '%s  %s\n' "$STARSHIP_INSTALLER_SHA256" "$installer" | sha256sum --check --status; then
    printf 'Starship installer checksum verification failed.\n' >&2
    exit 1
  fi
  "${SUDO[@]}" sh "$installer" --yes --version "$STARSHIP_VERSION"
  cleanup
  trap - EXIT
fi

if [[ -d "$REPO_DIR/.git" || -f "$REPO_DIR/.git" ]]; then
  if git -C "$REPO_DIR" remote get-url origin >/dev/null 2>&1; then
    git -C "$REPO_DIR" remote set-url origin "$REPOSITORY_URL"
  else
    git -C "$REPO_DIR" remote add origin "$REPOSITORY_URL"
  fi
  git -C "$REPO_DIR" fetch origin main
  current_branch=$(git -C "$REPO_DIR" symbolic-ref --quiet --short HEAD || true)
  if [[ "$current_branch" == "main" ]]; then
    git -C "$REPO_DIR" merge --ff-only origin/main
  else
    printf 'Repository is on %s; fetched main without changing branches.\n' "${current_branch:-a detached HEAD}"
  fi
else
  mkdir -p -- "$(dirname -- "$REPO_DIR")"
  git clone --branch main --single-branch "$REPOSITORY_URL" "$REPO_DIR"
fi

"$REPO_DIR/install.sh"
