#!/usr/bin/env bash

set -ue

GO_VER="1.24.4"
BTOP_VER="v1.4.3"
ARGO_VER="v2.14.14"
HELM_VER="v3.18.2"
K9S_VER="v0.50.6"
NVM_VER="v0.40.3"
KUBECTL_VER="v1.32.5"
SYNCTHING_VER="v1.29.7"

function essentials {
  sudo pacman -Syy --noconfirm base-devel tmux alacritty firefox gnome-shell-extensions gnome-browser-connector gnome-text-editor gnome-system-monitor gnome-tweaks nautilus obsidian curl unzip xsel ripgrep fd python-pip xdg-utils dnsutils net-tools iproute2 inetutils fcitx5-im fcitx5-chewing fcitx5-mozc
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

function install_reflector {
  sudo pacman -Syy --noconfirm reflector
  reflector --country Taiwan --protocol https --latest 20 --age 24 --sort rate | sudo tee /etc/pacman.d/mirrorlist
  sudo sed -i '/^\#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
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

function install_go {
  local fileName="go${GO_VER}.linux-amd64.tar.gz"
  local destDir="/usr/local"
  curl -LO https://go.dev/dl/${fileName}
  sudo rm -rf ${destDir}/go && sudo tar -C ${destDir} -xzf ${fileName}
  sudo ln -sf /usr/local/go/bin/go /usr/local/bin/go
  rm ./${fileName}
  export PATH=$PATH:/usr/local/go/bin
}

function install_rust {
  local rust="${HOME}/.cargo/env"
  if [ -f ${rust} ]; then
    . ${rust}
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . ${rust}
    rustup override set stable
    rustup update stable
  fi
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
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/${fileName}
  rm ${fileName}
}

function install_k9s {
  local fileName="k9s_Linux_amd64.tar.gz"
  curl -LO https://github.com/derailed/k9s/releases/download/${K9S_VER}/${fileName}
  sudo tar -zxf ${fileName} -C /usr/local/bin
  rm ${fileName}
}

function install_helm {
  local fileName="helm-${HELM_VER}-linux-amd64.tar.gz"
  curl -LO https://get.helm.sh/${fileName}
  tar -zxf ${fileName}
  sudo mv ./linux-amd64/helm /usr/local/bin/
  rm -rf ./linux-amd64
  rm ${fileName}
}

function install_argocd {
  sudo curl -sSLf -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/${ARGO_VER}/argocd-linux-amd64
  sudo chmod +x /usr/local/bin/argocd
}

function install_docker {
  sudo pacman -Syy --noconfirm docker docker-compose docker-buildx
  sudo systemctl enable --now docker.service
  sudo usermod -aG docker $USER
  newgrp docker && su - $USER

  # setup buildx
  docker run --privileged --rm tonistiigi/binfmt --install arm64
  sudo modprobe binfmt_misc
  sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
  docker buildx create --name multiarch-builder --driver docker-container --use
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
  local progs=(argocd aws btop docker go helm k9s kubectl nvm reflector rust syncthing virtualenv)
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
  local progs=(fonts nerdfonts alacritty tmux tpm nvim fcitx5)
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

  # black and typos
  sudo pacman -Syy --noconfirm python-black typos
}

function configShell {
  sudo cp -f ./shell/bash/completions/* /usr/share/bash-completion/completions/
  cp -f ./shell/gitconfig ~/.gitconfig
  cp -f ./shell/bash/bashrc ~/.bashrc
  source ~/.bashrc
}

essentials
installProgs
configProgs
installFormatters
configShell
