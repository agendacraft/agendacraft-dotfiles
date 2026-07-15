# AgendaCraft VPS dotfiles

```bash
git clone git@github.com:agendacraft/agendacraft-dotfiles.git && cd agendacraft-dotfiles
./bootstrap.sh
```

This private repository provides the interactive shell environment for AgendaCraft VPS hosts. It configures a production-forward Starship prompt, a practical offline-friendly tmux setup, and a small Bash startup snippet. It currently targets Ubuntu hosts using Bash (including the production droplet's `root` account).

`bootstrap.sh` is intended for a fresh Ubuntu box. It installs missing prerequisites, installs Starship with the official installer, updates or clones this repository, and then runs `install.sh`. Both scripts are safe to rerun. `install.sh` can also be run on its own when the prerequisites are already present.

## Private repository access

Configure access before using the quickstart. A read-only SSH deploy key is preferred on a VPS because it grants access only to this repository.

### Read-only deploy key (recommended)

Run these commands on the new host as the account that will own the dotfiles:

```bash
install -d -m 700 "$HOME/.ssh"
ssh-keygen -t ed25519 -N '' -C "agendacraft-dotfiles@$(hostname -f)" -f "$HOME/.ssh/agendacraft-dotfiles"
printf '%s\n' 'Host github.com' '  HostName github.com' '  User git' "  IdentityFile $HOME/.ssh/agendacraft-dotfiles" '  IdentitiesOnly yes' >> "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"
cat "$HOME/.ssh/agendacraft-dotfiles.pub"
```

In GitHub, open **agendacraft/agendacraft-dotfiles → Settings → Deploy keys → Add deploy key**, paste the printed public key, and leave **Allow write access** unchecked. Then verify access:

```bash
ssh -T git@github.com
git ls-remote git@github.com:agendacraft/agendacraft-dotfiles.git HEAD
```

If the host already uses a different `github.com` SSH identity, use a dedicated SSH host alias instead of appending the block above.

### GitHub CLI authentication (alternative)

If GitHub CLI is already installed and interactive user credentials are appropriate:

```bash
gh auth login --hostname github.com --git-protocol ssh --web
gh auth setup-git
git ls-remote git@github.com:agendacraft/agendacraft-dotfiles.git HEAD
```

## What gets installed

- `starship/starship.toml` → `~/.config/starship.toml`
- `tmux/tmux.conf` → `~/.tmux.conf`
- `shell/bashrc.d/agendacraft.sh` → `~/.config/agendacraft/bashrc.d/agendacraft.sh`
- A marker-guarded source block in `~/.bashrc`

The installer uses symlinks so repository updates take effect immediately. An existing regular file is moved to the corresponding `*.bak` path once before its symlink is created. If that backup already exists, the installer stops rather than overwrite it.

## Provisioning relationship

This repository owns user-facing shell configuration only. System provisioning belongs in the main `agendacraft` repository under `deploy/ansible/`. That provisioning will grow a role that installs and applies these dotfiles; it should invoke the scripts here rather than duplicate their contents.

## Add a new host

1. Provision the Ubuntu host through `agendacraft/deploy/ansible/`.
2. Give the target account read-only access to this private repository using a per-host deploy key (preferred) or GitHub CLI authentication.
3. Run the two-command quickstart as the target account.
4. Start a new login shell and confirm the prompt shows the expected red `PROD:<hostname>` marker; then run `tmux` and confirm the host and load appear in its status bar.

Do not share a private deploy key between hosts. Remove that host's deploy key from GitHub when the host is retired.
