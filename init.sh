#!/usr/bin/env bash

set -ue

GO_VER="1.23.5"
BTOP_VER="v1.4.0"
ARGO_VER="v2.13.4"
HELM_VER="v3.17.0"
K9S_VER="v0.32.7"
NVM_VER="v0.40.1"
KUBECTL_VER="v1.32.1"

function essentials {
  sudo pacman -Syy --noconfirm base-devel tmux alacritty curl unzip xsel ripgrep fd python-pip python-virtualenv
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

function install_go {
  local fileName="go${GO_VER}.linux-amd64.tar.gz"
  local destDir="/usr/local"
  curl -LO https://go.dev/dl/${fileName}
  sudo rm -rf ${destDir}/go && sudo tar -C ${destDir} -xzf ${fileName}
  sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
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
  sudo pip -q install virtualenv
  virtualenv -q ${HOME}/venv
  source ${HOME}/venv/bin/activate
}

function install_aws {
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
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
  local prog="/usr/local/bin/argocd"
  sudo curl -sSLf -o ${prog} https://github.com/argoproj/argo-cd/releases/download/${ARGO_VER}/argocd-linux-amd64
  sudo chmod +x ${prog}
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

function installProgs {
  local progs=(btop go rust nvm virtualenv aws kubectl k9s helm argocd)
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
  local progs=(nerdfonts alacritty tmux tpm nvim)
  for prog in "${progs[@]}"; do
    echo "configuring ${prog} ..."
    config_${prog}
    echo "${prog} has configured!"
  done
}

function installFormatters {
  # gofumpt, goimports-reviser
  go install mvdan.cc/gofumpt@latest
  go install github.com/incu6us/goimports-reviser/v3@latest

  # prettier
  npm install --global --force prettier

  # stylua
  curl -LO https://github.com/JohnnyMorganz/StyLua/releases/download/v2.0.2/stylua-linux-x86_64.zip
  sudo unzip -o stylua-linux-x86_64.zip -d /usr/local/bin/
  rm -f stylua-linux-x86_64.zip

  # shfmt
  sudo curl -sSLf -o /usr/local/bin/shfmt https://github.com/mvdan/sh/releases/download/v3.10.0/shfmt_v3.10.0_linux_amd64
  sudo chmod +x /usr/local/bin/shfmt

  # yamlfmt
  curl -LO https://github.com/google/yamlfmt/releases/download/v0.15.0/yamlfmt_0.15.0_Linux_x86_64.tar.gz
  sudo tar -zxf yamlfmt_0.15.0_Linux_x86_64.tar.gz -C /usr/local/bin
  rm -f yamlfmt_0.15.0_Linux_x86_64.tar.gz

  # python - black
  pip install --upgrade pip
  pip install black
}

essentials
installProgs
configProgs
installFormatters

exit 0
