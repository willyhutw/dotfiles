#!/usr/bin/env bash

set -ueo pipefail

cd "$(dirname "$(realpath "$0")")"

# The exact reverse of init.sh's config_* functions: copy the live config out of
# ~ and back into this repo, so edits made in place can be committed. Run this
# before `git add`, otherwise your changes never reach version control.
#
# Only the paths listed here are tracked. Anything else under ~/.claude
# (sessions, credentials, caches) is deliberately left alone.

function pull_file {
  local src="$1" dest="$2"
  if [ ! -e "${src}" ]; then
    echo "  skip  ${src} (not found)"
    return
  fi
  mkdir -p "$(dirname "${dest}")"
  cp -f "${src}" "${dest}"
  echo "  ok    ${src}"
}

function pull_dir {
  local src="$1" dest="$2"
  if [ ! -d "${src}" ]; then
    echo "  skip  ${src}/ (not found)"
    return
  fi
  mkdir -p "${dest}"
  cp -rf "${src}/." "${dest}/"
  echo "  ok    ${src}/"
}

# Refresh only the files this repo already has, so generated junk sitting next
# to them in the source directory never leaks in. Use this where the file list
# is a fixed set of overrides; use pull_dir where new files should be picked up.
function pull_existing {
  local srcDir="$1" destDir="$2"
  local dest
  for dest in "${destDir}"/*; do
    [ -f "${dest}" ] || continue
    pull_file "${srcDir}/$(basename "${dest}")" "${dest}"
  done
}

echo "shell:"
pull_file "${HOME}/.bashrc" shell/bash/bashrc
pull_file "${HOME}/.gitconfig" shell/gitconfig

echo "config:"
pull_dir "${HOME}/.config/alacritty" alacritty
pull_dir "${HOME}/.config/tmux" tmux
pull_dir "${HOME}/.config/nvim" nvim
pull_dir "${HOME}/.config/fcitx5" fcitx5
pull_file "${HOME}/.config/fontconfig/fonts.conf" fontconfig/fonts.conf
pull_file "${HOME}/.config/MangoHud/MangoHud.conf" mangohud/MangoHud.conf

echo "desktop:"
# fixed set of overrides -- ~/.local/share/applications also holds generated
# entries (mimeinfo.cache, syncthing-ui.desktop, ...) that must stay out
pull_existing "${HOME}/.local/share/applications" desktop/applications
pull_file "${HOME}/.config/mimeapps.list" desktop/mimeapps.list

# cron/crontab is edited here and pushed out with `crontab cron/crontab`,
# not pulled back -- `crontab -l` adds headers that would churn the file.

echo
echo "Done. Review with 'git status' / 'git diff', then commit."
