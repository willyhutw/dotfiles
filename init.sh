#!/usr/bin/env bash

set -ueo pipefail

cd "$(dirname "$(realpath "$0")")"

BTOP_VER="v1.4.5"
ARGO_VER="v3.3.0"
HELM_VER="v4.1.1"
K9S_VER="v0.50.18"
NVM_VER="v0.40.4"
KUBECTL_VER="v1.35.1"
SYNCTHING_VER="v2.0.14"

# This repo holds the master copy of every config file. The config_* functions
# below copy them out to where the applications actually read them. Nothing is
# symlinked, so edits made in ~ do not flow back here on their own -- run
# ./pull.sh to bring them in before committing.
function preflight {
  local missing=()
  local paths=(shell/bash/bashrc nvim/init.lua tmux/tmux.conf alacritty/alacritty.toml)
  for path in "${paths[@]}"; do
    [ -e "${path}" ] || missing+=("${path}")
  done
  if [ ${#missing[@]} -ne 0 ]; then
    echo "error: run this script from inside the dotfiles repo. Missing:" >&2
    printf '  %s\n' "${missing[@]}" >&2
    exit 1
  fi
}

function essentials {
  sudo sed -i '/^\#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf

  sudo pacman -Sy --needed --noconfirm reflector
  reflector -c tw -p https -a 24 --sort delay | sudo tee /etc/pacman.d/mirrorlist

  sudo pacman -Sy --needed --noconfirm \
    bash-completion \
    man-db \
    curl \
    rsync \
    unzip \
    less \
    fzf \
    bat \
    jq \
    yq \
    direnv \
    fastfetch \
    hugo \
    dnsutils \
    net-tools \
    iproute2 \
    inetutils \
    libmtp \
    gvfs-mtp \
    base-devel \
    go \
    opentofu \
    podman \
    speech-dispatcher \
    mangohud \
    cronie \
    uv \
    github-cli \
    age \
    btrfs-progs
  sudo systemctl enable --now cronie.service

  # keep user services (syncthing, hermes) running without a login session
  sudo loginctl enable-linger $USER
}

function install_btop {
  local prog="btop"
  local fileName="btop-i686-linux-musl.tbz"
  curl -LO https://github.com/aristocratos/btop/releases/download/${BTOP_VER}/${fileName}
  tar -xf ${fileName}
  (cd ${prog} && sudo ./install.sh)
  rm -rf ${prog}
  rm ${fileName}
}

function install_syncthing {
  local prog="syncthing"
  local fileName="${prog}-linux-amd64-${SYNCTHING_VER}.tar.gz"
  curl -LOs "https://github.com/${prog}/${prog}/releases/download/${SYNCTHING_VER}/${fileName}"
  sudo rm -rf /opt/${prog}
  sudo tar -zxf ./${fileName} -C /opt
  sudo mv /opt/${fileName%.tar.gz} /opt/${prog}
  sudo chown -R $USER:$USER /opt/${prog}
  sudo ln -sf /opt/${prog}/syncthing /usr/bin/syncthing
  mkdir -p ~/.config/systemd/user
  ln -sf /opt/syncthing/etc/linux-systemd/user/syncthing.service ~/.config/systemd/user/
  systemctl --user enable --now syncthing.service
  mkdir -p ~/.local/share/{applications,icons}
  ln -sf /opt/syncthing/etc/linux-desktop/syncthing-ui.desktop ~/.local/share/applications/
  curl -sSLf -o ~/.local/share/icons/syncthing.png "https://raw.githubusercontent.com/${prog}/${prog}/refs/heads/main/assets/logo-128.png"
  rm -f ./${fileName}
}

function install_nvm {
  local nvm=${HOME}/.nvm/nvm.sh
  if [ ! -f ${nvm} ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VER}/install.sh | bash
  fi
  . ${nvm}
  nvm install --lts
}

function install_aws {
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -qq awscliv2.zip
  sudo ./aws/install
  rm awscliv2.zip
  rm -rf ./aws
}

function install_kubectl {
  local fileName="kubectl"
  curl -LO https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/${fileName}
  sudo install -o root -g root -m 0755 ${fileName} /usr/local/bin/${fileName}
  rm ${fileName}
}

function install_k9s {
  local fileName="k9s_Linux_amd64.tar.gz"
  curl -LO https://github.com/derailed/k9s/releases/download/${K9S_VER}/${fileName}
  sudo tar -zxf ${fileName} -C /usr/local/bin
  sudo chmod +x /usr/local/bin/k9s
  rm ${fileName}
}

function install_helm {
  local fileName="helm-${HELM_VER}-linux-amd64.tar.gz"
  curl -LO https://get.helm.sh/${fileName}
  tar -zxf ${fileName}
  sudo install -o root -g root -m 0755 ./linux-amd64/helm /usr/local/bin/helm
  rm -rf ./linux-amd64
  rm ${fileName}
}

function install_argocd {
  local fileName="argocd-linux-amd64"
  curl -LO https://github.com/argoproj/argo-cd/releases/download/${ARGO_VER}/${fileName}
  sudo install -o root -g root -m 0755 ${fileName} /usr/local/bin/argocd
  rm -f ${fileName}
}

function install_yay {
  local prog="yay-bin"
  git clone https://aur.archlinux.org/${prog}.git
  (cd ${prog} && makepkg -si --noconfirm)
  rm -rf ${prog}
}

function config_fonts {
  local cfgDir="${HOME}/.config/fontconfig"
  echo "Installing noto fonts ..."
  sudo pacman -S --needed --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji
  mkdir -p ${cfgDir}
  cp -f fontconfig/fonts.conf ${cfgDir}/
  fc-cache -f
}

function config_nerdfonts {
  local tag="v3.4.0"
  local fontDir="/usr/local/share/fonts"
  local fonts=(FiraCode Hack JetBrainsMono)
  for font in "${fonts[@]}"; do
    echo "checking ${font}NerdFont ..."
    if [ ! -f ${fontDir}/${font}NerdFont-Regular.ttf ]; then
      echo "${font}NerdFont not found! Installing ..."
      curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/${tag}/${font}.zip
      sudo unzip -qq -o ${font}.zip -d ${fontDir}
      rm ${font}.zip
    fi
  done
  fc-cache -f
}

function config_alacritty {
  local cfgDir="${HOME}/.config/alacritty"
  mkdir -p ${cfgDir}
  cp -rf alacritty/. ${cfgDir}/
}

function config_tmux {
  local cfgDir="${HOME}/.config/tmux"
  mkdir -p ${cfgDir}
  cp -rf tmux/. ${cfgDir}/
}

function config_tpm {
  local tag="3.1.0"
  local pluginDir="${HOME}/.tmux/plugins"
  if [ ! -d ${pluginDir}/tpm ]; then
    mkdir -p ${pluginDir}
    curl -LO https://github.com/tmux-plugins/tpm/archive/refs/tags/v${tag}.tar.gz
    tar -zxf v${tag}.tar.gz -C ${pluginDir}
    mv ${pluginDir}/tpm-${tag} ${pluginDir}/tpm
    rm v${tag}.tar.gz
  fi
}

function config_mangohud {
  local cfgDir="${HOME}/.config/MangoHud"
  mkdir -p ${cfgDir}
  cp -f mangohud/MangoHud.conf ${cfgDir}/
}

function config_nvim {
  local cfgDir="${HOME}/.config/nvim"

  sudo pacman -S --needed --noconfirm \
    fd \
    ripgrep \
    xsel \
    stylua \
    shfmt \
    yamlfmt \
    lynx \
    tree-sitter

  yay -S --needed --noconfirm \
    luajit-tiktoken-bin \
    --answerclean A \
    --answerdiff N \
    --removemake

  mkdir -p ${cfgDir}
  cp -rf nvim/. ${cfgDir}/
}

function config_fcitx5 {
  local cfgDir="${HOME}/.config/fcitx5"
  mkdir -p ${cfgDir}
  cp -rf fcitx5/. ${cfgDir}/
}

# only the keys in the file are set; everything else keeps GNOME's defaults
function config_gnome {
  dconf load / <gnome/settings.dconf
}

# takes effect on next boot
function config_zram {
  sudo pacman -S --needed --noconfirm zram-generator
  sudo cp -f zram/zram-generator.conf /etc/systemd/
}

function installProgs {
  local progs=(argocd aws btop helm k9s kubectl nvm syncthing yay)
  for prog in "${progs[@]}"; do
    echo "checking ${prog} ..."
    if ! command -v ${prog} &>/dev/null; then
      echo "${prog} not found! Installing ..."
      install_${prog}
    fi
    echo "${prog} is ready!"
  done
}

function configProgs {
  local progs=(alacritty fcitx5 fonts gnome mangohud nerdfonts nvim tmux tpm zram)
  for prog in "${progs[@]}"; do
    echo "configuring ${prog} ..."
    config_${prog}
    echo "${prog} has configured!"
  done
}

function installFormatters {
  npm install --global --force prettier
}

function configShell {
  # bash completion
  mkdir -p ${HOME}/.local/share/bash-completion/completions
  kubectl completion bash >${HOME}/.local/share/bash-completion/completions/kubectl
  k9s completion bash >${HOME}/.local/share/bash-completion/completions/k9s
  helm completion bash >${HOME}/.local/share/bash-completion/completions/helm
  argocd completion bash >${HOME}/.local/share/bash-completion/completions/argocd

  # git config
  cp -f shell/gitconfig ${HOME}/.gitconfig

  # bashrc
  cp -f shell/bash/bashrc ${HOME}/.bashrc
}

function installLibvirt {
  sudo pacman -S --needed --noconfirm \
    libvirt \
    virt-manager \
    iproute2 \
    qemu-base \
    cloud-image-utils \
    whois \
    dnsmasq

  sudo systemctl enable --now libvirtd.service
  sudo virsh net-start default
  sudo virsh net-autostart default
  sudo usermod -aG libvirt $USER
}

function installGUIApps {
  sudo pacman -S --needed --noconfirm \
    fcitx5-im \
    fcitx5-chewing \
    fcitx5-mozc \
    firefox \
    gnome-shell-extensions \
    gnome-browser-connector \
    gnome-text-editor \
    gnome-calculator \
    gnome-system-monitor \
    gnome-tweaks \
    gnome-clocks \
    nautilus \
    obsidian \
    xdg-utils \
    vlc \
    vlc-plugin-ffmpeg \
    seahorse

  # BambuStudio AppImage runtime
  sudo pacman -S --needed --noconfirm fuse2 webkit2gtk-4.1

  yay -S --needed --noconfirm \
    google-chrome \
    visual-studio-code-bin \
    downgrade \
    gnome-shell-extension-kimpanel-git \
    --answerclean A \
    --answerdiff N \
    --removemake

  # override gnome desktop applications
  mkdir -p ${HOME}/.local/share/applications
  cp -f desktop/applications/*.desktop ${HOME}/.local/share/applications/
  cp -f desktop/mimeapps.list ${HOME}/.config/
  update-desktop-database ${HOME}/.local/share/applications/
}

function installGames {
  # linux-headers is for xpadneo-dkms
  sudo pacman -S --needed --noconfirm \
    steam \
    linux-headers

  yay -S --needed --noconfirm \
    pcsx2-latest-bin \
    rpcs3-bin \
    xpadneo-dkms \
    --answerclean A \
    --answerdiff N \
    --removemake
}

function installAsusctl {
  yay -S --needed --noconfirm \
    asusctl-devel-git \
    --answerclean A \
    --answerdiff N \
    --removemake

  # asusd is a static unit pulled in by udev, so start it instead of enable
  sudo systemctl start asusd.service
  asusctl profile set Quiet -a
  asusctl profile set Quiet -b
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  preflight
  essentials
  installProgs
  configProgs
  installFormatters
  configShell
  installGUIApps
  installGames
  echo "Done. Open a new shell (or run 'exec bash') to pick up the config."
fi

# === Optional ===
# installLibvirt
# installAsusctl
