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
  sudo pacman -Syy --noconfirm reflector
  reflector -c tw -p https -a 24 --sort delay | sudo tee /etc/pacman.d/mirrorlist

  sudo pacman -Syy --noconfirm \
    base-devel \
    clang \
    python-pip \
    go \
    rust \
    alacritty \
    tmux \
    curl \
    unzip \
    dnsutils \
    net-tools \
    iproute2 \
    inetutils \
    fd \
    ripgrep \
    xsel \
    xdg-utils \
    firefox \
    obsidian \
    gnome-shell-extensions \
    gnome-browser-connector \
    gnome-text-editor \
    gnome-system-monitor \
    gnome-tweaks \
    nautilus \
    fcitx5-im \
    fcitx5-chewing \
    fcitx5-mozc \
    docker \
    docker-compose \
    docker-buildx

  sudo systemctl enable --now docker.service
  sudo usermod -aG docker $USER
  newgrp docker
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
  curl -LOs "https://github.com/${prog}/${prog}/releases/download/${SYNCTHING_VER}/${prog}-linux-amd64-${SYNCTHING_VER}.tar.gz"
  sudo tar -zxf ./${prog}-linux-amd64-${SYNCTHING_VER}.tar.gz -C /opt
  sudo mv /opt/${prog}-linux-amd64-${SYNCTHING_VER} /opt/${prog}
  sudo ln -sf /opt/${prog}/syncthing /usr/bin/syncthing
  mkdir -p ~/.local/share/icons
  sudo curl -sSLf -o ~/.local/share/icons/syncthing.png "https://raw.githubusercontent.com/${prog}/${prog}/refs/heads/main/assets/logo-128.png"
  mkdir -p ~/.config/systemd/user
  ln -sf /opt/syncthing/etc/linux-systemd/user/syncthing.service ~/.config/systemd/user/
  ln -sf /opt/syncthing/etc/linux-desktop/syncthing-ui.desktop ~/.local/share/applications/
  systemctl --user enable --now syncthing.service
  rm -f ./${prog}-linux-amd64-${SYNCTHING_VER}.tar.gz
}

function install_nvm {
  local nvm=${HOME}/.nvm/nvm.sh
  if [ ! -f ${nvm} ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VER}/install.sh | bash
  fi
  . ${nvm}
  nvm install --lts
}

function install_virtualenv {
  sudo pip -q install virtualenv --break-system-packages
  virtualenv -q ${HOME}/venv
  source ${HOME}/venv/bin/activate
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

function config_buildx {
  docker run --privileged --rm tonistiigi/binfmt --install arm,arm64
  sudo modprobe binfmt_misc
  sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
  docker buildx inspect --bootstrap
}

function config_fonts {
  local fontCfgDir="${HOME}/.config/fontconfig"
  mkdir -p ${fontCfgDir}
  if [ ! -f ${fontCfgDir}/fonts.conf ]; then
    echo "FontConfig not found! Installing noto fonts ..."
    sudo pacman -Syy --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji
    fc-cache -f
    cp ./fontconfig/fonts.conf ${fontCfgDir}/fonts.conf
  fi
}

function config_nerdfonts {
  local tag="v3.2.0"
  local fontDir="/usr/local/share/fonts"
  local fonts=("Hack")
  for font in "${fonts[@]}"; do
    if [ ! -f ${fontDir}/${font}NerdFont-Regular.ttf ]; then
      echo "${font}NerdFont not found! Installing ..."
      curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/${tag}/${font}.zip
      sudo unzip -o ${font}.zip -d ${fontDir}
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
  local progs=(argocd aws btop helm k9s kubectl nvm syncthing virtualenv)
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
  local progs=(alacritty buildx fcitx5 fonts nerdfonts nvim tmux tpm)
  for prog in "${progs[@]}"; do
    echo "configuring ${prog} ..."
    config_${prog}
    echo "${prog} has configured!"
  done
}

function installFormatters {
  # prettier
  npm install --global --force prettier

  # stylua
  curl -LO https://github.com/JohnnyMorganz/StyLua/releases/download/v2.1.0/stylua-linux-x86_64.zip
  sudo unzip -o stylua-linux-x86_64.zip -d /usr/local/bin/
  rm -f stylua-linux-x86_64.zip

  # shfmt
  sudo curl -sSLf -o /usr/local/bin/shfmt https://github.com/mvdan/sh/releases/download/v3.11.0/shfmt_v3.11.0_linux_amd64
  sudo chmod +x /usr/local/bin/shfmt

  # yamlfmt
  curl -LO https://github.com/google/yamlfmt/releases/download/v0.17.0/yamlfmt_0.17.0_Linux_x86_64.tar.gz
  sudo tar -zxf yamlfmt_0.17.0_Linux_x86_64.tar.gz -C /usr/local/bin
  rm -f yamlfmt_0.17.0_Linux_x86_64.tar.gz

  # black for python
  sudo pacman -Syy --noconfirm python-black
}

function configShell {
  sudo cp -f ./shell/bash/completions/* /usr/share/bash-completion/completions/
  cp -f ./shell/gitconfig ~/.gitconfig
  cp -f ./shell/bash/bashrc ~/.bashrc
  source ~/.bashrc
}

function installAsusctl {
  local progs=(asusctl supergfxctl)
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

# optional
installAsusctl
