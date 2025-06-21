#!/usr/bin/env bash

set -ue

BTOP_VER="v1.4.3"
ARGO_VER="v2.14.14"
HELM_VER="v3.18.2"
K9S_VER="v0.50.6"
NVM_VER="v0.40.3"
KUBECTL_VER="v1.32.5"
SYNCTHING_VER="v1.29.7"
ASUSCTL_VER="6.1.12"
SUPERGFXCTL_VER="5.2.7"

function essentials {
  sudo sed -i '/^\#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf

  sudo pacman -Sy --needed --noconfirm reflector
  reflector -c tw -p https -a 24 --sort delay | sudo tee /etc/pacman.d/mirrorlist

  sudo pacman -Sy --needed --noconfirm \
    man-db \
    curl \
    unzip \
    less \
    fzf \
    bat \
    jq \
    yq \
    dnsutils \
    net-tools \
    iproute2 \
    inetutils \
    libmtp \
    gvfs-mtp \
    base-devel \
    uv \
    go
}

function install_btop {
  local prog="btop"
  local fileName="btop-i686-linux-musl.tbz"
  curl -LO https://github.com/aristocratos/btop/releases/download/${BTOP_VER}/${fileName}
  tar -xf ${fileName}
  cd ${prog}
  sudo ./install.sh
  cd ..
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
  sudo curl -LO https://github.com/argoproj/argo-cd/releases/download/${ARGO_VER}/${fileName}
  sudo install -o root -g root -m 0755 ${fileName} /usr/local/bin/argocd
  rm -f ${fileName}
}

function install_asusctl {
  local prog="asusctl"
  git clone --depth 1 --branch ${ASUSCTL_VER} https://gitlab.com/asus-linux/${prog}.git
  cd ${prog}
  make && sudo make install
  sudo systemctl enable --now asusd.service
  cd ..
  rm -rf ${prog}
}

function install_supergfxctl {
  local prog="supergfxctl"
  git clone --depth 1 --branch ${SUPERGFXCTL_VER} https://gitlab.com/asus-linux/${prog}.git
  cd ${prog}
  make && sudo make install
  sudo systemctl enable --now supergfxd.service
  cd ..
  rm -rf ${prog}
}

function install_yay {
  local prog="yay-bin"
  git clone https://aur.archlinux.org/${prog}.git
  cd ${prog}
  makepkg -si --noconfirm
  cd ..
  rm -rf ${prog}
}

function config_fonts {
  local fontCfgDir="${HOME}/.config/fontconfig"
  mkdir -p ${fontCfgDir}
  if [ ! -f ${fontCfgDir}/fonts.conf ]; then
    echo "FontConfig not found! Installing noto fonts ..."
    sudo pacman -S --needed --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji
    fc-cache -f
    cp ./fontconfig/fonts.conf ${fontCfgDir}/fonts.conf
  fi
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
  local prog="alacritty"
  local cfgDir=${HOME}/.config/${prog}
  mkdir -p ${cfgDir}/themes
  cp ${prog}/${prog}.toml ${cfgDir}
  local themes=("tokyonight_night" "gruvbox_dark")
  for theme in "${themes[@]}"; do
    cp ${prog}/themes/${theme}.toml ${cfgDir}/themes
  done
}

function config_tmux {
  local cfgDir=${HOME}/.config/tmux
  mkdir -p ${cfgDir}/themes
  cp tmux/tmux.conf ${cfgDir}
  local themes=("tokyonight_night" "gruvbox_dark")
  for theme in "${themes[@]}"; do
    cp tmux/themes/${theme}.tmux ${cfgDir}/themes
  done
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

function config_nvim {
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

  local destDir="${HOME}/.config/nvim"
  if [ ! -d ${destDir} ]; then
    mkdir -p ${destDir}
    cp -rf nvim/* ${destDir}/
  fi
}

function config_fcitx5 {
  cp -rf ./fcitx5 ~/.config/
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
  local progs=(alacritty fcitx5 fonts nerdfonts nvim tmux tpm)
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
  cp -f ./shell/gitconfig ~/.gitconfig

  # bashrc
  cp -f ./shell/bash/bashrc ~/.bashrc
  source ~/.bashrc
}

function installDocker {
  sudo pacman -S --needed --noconfirm \
    docker \
    docker-compose \
    docker-buildx
  sudo systemctl enable --now docker.service
  sudo usermod -aG docker $USER
}

function installLibvirt {
  sudo pacman -S --needed --noconfirm \
    libvirt \
    virt-manager \
    bridge-utils \
    qemu-base \
    bridge-utils \
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
    gnome-system-monitor \
    gnome-tweaks \
    nautilus \
    obsidian \
    xdg-utils
}

function installAsusctl {
  local progs=(asusctl supergfxctl)
  sudo pacman -S --needed --noconfirm clang
  for prog in "${progs[@]}"; do
    if ! command -v ${prog} &>/dev/null; then
      echo "${prog} not found! Installing ..."
      install_${prog}
    fi
    echo "${prog} is ready!"
  done
}

essentials
installProgs
configProgs
installFormatters
configShell
installGUIApps

# optional
# installDocker
# installLibvirt
# installAsusctl
