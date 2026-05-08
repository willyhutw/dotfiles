# dotfiles

Personal dotfiles managed with a bare git repository. Files are checked out directly to `~`, so no symlinks are needed.

## First-time setup on a new machine

### 1. Clone the bare repo

No SSH key required at this stage — use HTTPS:

```bash
git clone --bare https://github.com/willyhutw/dotfiles.git ~/.dotfiles
```

### 2. Check out files

```bash
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout
```

If git reports conflicts (files already exist at target paths), remove or back them up and re-run.

### 3. Configure the repo

```bash
git --git-dir=$HOME/.dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no
```

### 4. Load the shell config

```bash
source ~/.bashrc
```

The `dotfiles` alias is now available.

### 5. Run the setup script

```bash
~/.config/dotfiles/init.sh
```

This installs packages, tools, and runs remaining configuration steps.

### 6. Switch remote to SSH (after setting up SSH keys)

```bash
dotfiles remote set-url origin git@github.com:willyhutw/dotfiles.git
```

## Daily usage

```bash
dotfiles status                        # show tracked files with changes
dotfiles add ~/.config/nvim/init.lua   # stage a change
dotfiles commit -m "..."
dotfiles push

dotfiles add -f ~/.config/newapp/config  # track a new file (-f required due to .gitignore)
```
