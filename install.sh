#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
CONFIG_DIR=${XDG_CONFIG_HOME:-"$HOME/.config"}
SHELL_SNIPPET_DIR="$CONFIG_DIR/agendacraft/bashrc.d"
BASHRC="$HOME/.bashrc"
MARKER_START="# >>> agendacraft dotfiles >>>"

backup_and_link() {
  local source=$1
  local destination=$2
  local backup="${destination}.bak"

  mkdir -p -- "$(dirname -- "$destination")"

  if [[ -L "$destination" ]]; then
    ln -sfn -- "$source" "$destination"
    return
  fi

  if [[ -e "$destination" ]]; then
    if [[ -e "$backup" || -L "$backup" ]]; then
      printf 'Refusing to replace %s: backup already exists at %s\n' "$destination" "$backup" >&2
      return 1
    fi
    mv -- "$destination" "$backup"
    printf 'Backed up %s to %s\n' "$destination" "$backup"
  fi

  ln -s -- "$source" "$destination"
}

backup_and_link "$REPO_DIR/starship/starship.toml" "$CONFIG_DIR/starship.toml"
backup_and_link "$REPO_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
backup_and_link "$REPO_DIR/shell/bashrc.d/agendacraft.sh" "$SHELL_SNIPPET_DIR/agendacraft.sh"

touch -- "$BASHRC"
if ! grep -Fqx -- "$MARKER_START" "$BASHRC"; then
  cat >> "$BASHRC" <<'EOF'

# >>> agendacraft dotfiles >>>
if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/agendacraft/bashrc.d/agendacraft.sh" ]; then
  . "${XDG_CONFIG_HOME:-$HOME/.config}/agendacraft/bashrc.d/agendacraft.sh"
fi
# <<< agendacraft dotfiles <<<
EOF
fi

printf 'AgendaCraft dotfiles installed. Start a new Bash shell to activate them.\n'
