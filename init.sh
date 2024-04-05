#! /usr/bin/env bash

set -u

function install_pkgs {
	sudo apt update &&
		sudo apt install -y \
			vim \
			git \
			tmux \
			curl \
			python3-pip \
			xsel \
			acpi \
			sysstat \
			lm-sensors \
			ripgrep \
			fd-find
}

function check_btop {
	echo "checking btop ..."
	which btop &>/dev/null
	if [ $? != 0 ]; then
		echo "installing btop ..."
		tag="v1.3.2"
		curl -sLO https://github.com/aristocratos/btop/releases/download/$tag/btop-i686-linux-musl.tbz
		tar -xf btop-i686-linux-musl.tbz
		cd btop
		sudo ./install.sh
		cd ..
	fi
	echo "btop is ready!"
}

function check_alacritty {
	echo "checking alacritty ..."
	which alacritty &>/dev/null
	if [ $? != 0 ]; then
		echo "installing alacritty ..."
		sudo snap install --classic alacritty
	fi
	echo "alacritty is ready!"
}

function update_alacritty_conf {
	echo "updating alacritty config ..."
	destDir=$HOME/.config/alacritty
	mkdir -p $destDir/themes
	cp ./alacritty/alacritty.toml $destDir/alacritty.toml
	cp ./alacritty/themes/gruvbox_dark.toml $destDir/themes/gruvbox_dark.toml
	echo "alacritty config has been updated!"
}

function check_tpm {
	echo "checking tpm ..."
	if [ ! -d $destDir/tpm ]; then
		echo "installing tpm ..."
		tag="3.1.0"
		url="https://github.com/tmux-plugins/tpm/archive/refs/tags/v$tag.tar.gz"
		destDir="$HOME/.tmux/plugins"
		curl -sLO $url
		tar -zxf v$tag.tar.gz -C $destDir
		mv $destDir/tpm-$tag $destDir/tpm
		rm v$tag.tar.gz
	fi
	echo "tpm is ready!"
}

function update_tmux_conf {
	echo "updating tmux config ..."
	destDir=$HOME/.config/tmux
	mkdir -p $destDir
	cp ./tmux/tmux.conf $destDir/tmux.conf
	echo "tmux config has been updated!"
}

function update_vimrc {
	echo "updating vim config ..."
	cp ./vim/vimrc $HOME/.vimrc
	echo "vim config has been updated!"
}

function check_neovim {
	echo "checking neovim ..."
	tag="v0.9.5"
	filename="nvim-linux64"
	which nvim &>/dev/null
	if [ $? != 0 ]; then
		echo "installing neovim ..."
		curl -sLO https://github.com/neovim/neovim/releases/download/$tag/$filename.tar.gz
		sudo tar -zxf $filename.tar.gz -C /opt
		sudo ln -s /opt/$filename/bin/nvim /usr/local/bin/nvim
		rm $filename.tar.gz
	fi
	echo "neovim is ready!"
}

function setup_lazyvim {
	echo "installing lazyvim ..."
	destDir="$HOME/.config/nvim"
	rm -rf $HOME/.local/share/nvim
	rm -rf $HOME/.local/state/nvim
	rm -rf $destDir
	cp -rf ./nvim $destDir
	echo "lazyvim is ready!"
}

function check_nvm {
	echo "checking nvm & node ..."
	which nvm &>/dev/null
	if [ $? != 0 ]; then
		echo "installing nvm & node ..."
		tag="v0.39.7"
		curl -sLO https://raw.githubusercontent.com/nvm-sh/nvm/$tag/install.sh
		chmod +x install.sh
		./install.sh
		export NVM_DIR="$HOME/.config/nvm"
		[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
		[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
		nvm install --lts
		rm ./install.sh
	fi
	echo "nvm & node is ready!"
}

function check_go {
	echo "checking go ..."
	which go &>/dev/null
	if [ $? != 0 ]; then
		echo "installing go ..."
		filename="go1.22.2.linux-amd64.tar.gz"
		targetDir="/usr/local"
		curl -sLO https://go.dev/dl/$filename
		sudo rm -rf $targetDir/go && sudo tar -C $targetDir -xzf $filename
		rm ./$filename
	fi
	echo "go is ready!"
}

function setup_python_venv {
	echo "installing python venv ..."
	sudo pip install virtualenv
	virtualenv venv
	echo "python venv is ready!"
}

function setup_nerdfonts {
	echo "installing nerd fonts ..."
	fonts=("FiraMono" "Hack" "UbuntuMono")
	for font in ${fonts[@]}; do
		tag="v3.2.0"
		curl -sLO https://github.com/ryanoasis/nerd-fonts/releases/download/$tag/$font.zip
		sudo unzip -qo $font.zip -d /usr/local/share/fonts
		rm $font.zip
	done
	fc-cache -f
	echo "nerd fonts is ready!"
}

function check_kubectl {
	echo "checking kubectl ..."
	which kubectl &>/dev/null
	if [ $? != 0 ]; then
		echo "installing kubectl ..."
		tag="v1.28.7"
		curl -sLO https://dl.k8s.io/release/$tag/bin/linux/amd64/kubectl
		sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
		rm kubectl
	fi
	echo "kubectl is ready!"
}

function check_k9s {
	echo "checking k9s ..."
	which k9s &>/dev/null
	if [ $? != 0 ]; then
		echo "installing k9s ..."
		tag="v0.32.4"
	  filename="k9s_Linux_amd64.tar.gz"
		curl -sLO https://github.com/derailed/k9s/releases/download/$tag/$filename
		sudo tar -zxf $filename -C /usr/local/bin
		rm $filename
	fi
	echo "k9s is ready!"
}

function check_helm {
	echo "checking helm ..."
	which helm &>/dev/null
	if [ $? != 0 ]; then
		echo "installing helm ..."
		tag="v3.14.3"
		filename="helm-$tag-linux-amd64.tar.gz"
		curl -sLO https://get.helm.sh/$filename
		tar -zxf $filename
		sudo mv ./linux-amd64/helm /usr/local/bin/
		rm -rf ./linux-amd64
		rm $filename
	fi
	echo "helm is ready!"
}

function update_bashrc {
	echo "updating bashrc ..."
	cp -f ./bashrc $HOME/.bashrc
	echo "bashrc has been updated!"
}

install_pkgs
check_btop
check_alacritty
update_alacritty_conf
check_tpm
update_tmux_conf
update_vimrc
check_neovim
setup_lazyvim
check_nvm
check_go
setup_python_venv
setup_nerdfonts
check_kubectl
check_k9s
check_helm
update_bashrc

exit 0
