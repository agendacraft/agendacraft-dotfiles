# AgendaCraft VPS dotfiles

```bash
git clone https://github.com/agendacraft/agendacraft-dotfiles.git && cd agendacraft-dotfiles
./bootstrap.sh
```

The clone-first quickstart assumes Git is already available. On a completely minimal Ubuntu/Debian image, install the clone prerequisites first, then run the two commands above:

```bash
apt-get update && apt-get install -y --no-install-recommends git ca-certificates
```

This public repository provides the interactive shell environment for AgendaCraft VPS hosts. It configures Starship, a practical offline-friendly tmux setup, and a small Bash startup snippet. It currently targets Ubuntu hosts using Bash (including the production droplet's `root` account). No credentials, deploy keys, or GitHub login are needed to clone or update it.

`bootstrap.sh` is intended for a fresh Ubuntu box. It installs missing prerequisites, installs Starship with the official installer, updates or clones this repository, and then runs `install.sh`. Both scripts are safe to rerun. `install.sh` can also be run on its own when the prerequisites are already present.

## What gets installed

- `starship/starship.toml` → `~/.config/starship.toml`
- `tmux/tmux.conf` → `~/.tmux.conf`
- `shell/bashrc.d/agendacraft.sh` → `~/.config/agendacraft/bashrc.d/agendacraft.sh`
- A marker-guarded source block in `~/.bashrc`

The installer uses symlinks so repository updates take effect immediately. An existing regular file is moved to the corresponding `*.bak` path once before its symlink is created. If that backup already exists, the installer stops rather than overwrite it.

The Starship config intentionally has no overrides: it uses the built-in prompt, which shows the hostname for SSH sessions. AgendaCraft hostnames already identify their environment, so no separate `PROD` or `STAGE` banner is added. tmux likewise displays the hostname without an environment label.

## Provisioning relationship

This repository owns user-facing shell configuration only. System provisioning belongs in the main `agendacraft` repository under `deploy/ansible/`. That provisioning will grow a role that installs and applies these dotfiles; it should invoke the scripts here rather than duplicate their contents.

## Add a new host

1. Provision the Ubuntu host through `agendacraft/deploy/ansible/`.
2. Run the two-command quickstart as the target account; the public repository requires no credentials.
3. Start a new SSH login shell and confirm the prompt shows the expected hostname; then run `tmux` and confirm the host and load appear in its status bar.
