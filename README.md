# dotfiles

Personal dotfiles for Arch Linux + GNOME. This repo holds the master copy of
every config file; `init.sh` copies them out to the paths the applications
actually read. Nothing is symlinked.

## First-time setup on a new machine

### 1. Clone the repo

No SSH key required at this stage — use HTTPS:

```bash
git clone https://github.com/willyhutw/dotfiles.git ~/dotfiles
```

### 2. Run the setup script

```bash
~/dotfiles/init.sh
```

This installs packages and tools, then copies every config file into place.
Existing files at those paths are overwritten, so back up anything you want to
keep first.

### 3. Load the shell config

```bash
exec bash
```

### 4. Switch remote to SSH (after setting up SSH keys)

```bash
cd ~/dotfiles
git remote set-url origin git@github.com:willyhutw/dotfiles.git
```

## Daily usage

Configs are **copied**, not linked, so changes flow in one direction at a time.

**Changing a config:** edit it wherever you normally would, then pull it back
into the repo before committing:

```bash
vim ~/.config/nvim/init.lua   # edit in place, as usual
cd ~/dotfiles
./pull.sh                     # copy ~ -> repo
git diff                      # check what actually changed
git add -A && git commit -m "nvim: ..."
git push
```

`./pull.sh` is the exact reverse of `init.sh`'s `config_*` functions. **If you
skip it, your edits never reach version control.**

**Applying the repo to the machine** (e.g. after `git pull` on another host):

```bash
cd ~/dotfiles
./init.sh                     # copy repo -> ~, plus package installs
```

To only push configs out without touching packages, source the script and call
the pieces you want:

```bash
cd ~/dotfiles
source ./init.sh && configProgs && configShell
```

## Layout

| Repo path | Copied to |
|---|---|
| `shell/bash/bashrc` | `~/.bashrc` |
| `shell/gitconfig` | `~/.gitconfig` |
| `shell/gitconfig-clario` | `~/.gitconfig-clario` |
| `alacritty/` | `~/.config/alacritty/` |
| `tmux/` | `~/.config/tmux/` |
| `nvim/` | `~/.config/nvim/` |
| `fcitx5/` | `~/.config/fcitx5/` |
| `fontconfig/fonts.conf` | `~/.config/fontconfig/` |
| `mangohud/MangoHud.conf` | `~/.config/MangoHud/` |
| `claude/` | `~/.claude/` |
| `desktop/applications/` | `~/.local/share/applications/` |
| `desktop/mimeapps.list` | `~/.config/` |
| `cron/crontab` | installed with `crontab` |

`init.sh` and `archinstall.sh` are provisioning scripts and are not copied
anywhere. `cron/crontab` is edited here and pushed out by `config_cron`; it is
not pulled back, because `crontab -l` adds headers that churn the file.

Only the paths in the table are tracked. Everything else under `~/.claude`
(sessions, credentials, caches) is deliberately left alone by both scripts.
