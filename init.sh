#! /usr/bin/env bash

set -u

function essentials {
	sudo apt update -qq \
		&& sudo apt install -qqy \
			vim \
			git \
			tmux \
			curl \
			python3-pip \
			acpi \
			lm-sensors \
			sysstat \
			xsel \
			ripgrep \
			fd-find
}

#TODO: Build from source.
function install_alacritty {
	sudo snap install --classic alacritty
}

function config_alacritty {
	prog="alacritty"
	theme="gruvbox_dark"
	cfgDir=$HOME/.config/$prog
	mkdir -p $cfgDir/themes
	cp ./$prog/$prog.toml $cfgDir/$prog.toml
	cp ./$prog/themes/$theme.toml $cfgDir/themes/$theme.toml
}

function install_btop {
	tag="v1.3.2"
	prog="btop"
	fileName="btop-i686-linux-musl.tbz"
	curl -sLO https://github.com/aristocratos/btop/releases/download/$tag/$fileName
	tar -xf $fileName
	cd $prog
	sudo ./install.sh
	cd ..
	rm -rf $prog
	rm $fileName
}

function install_go {
	fileName="go1.22.2.linux-amd64.tar.gz"
	destDir="/usr/local"
	curl -sLO https://go.dev/dl/$fileName
	sudo rm -rf $destDir/go && sudo tar -C $destDir -xzf $fileName
	rm ./$fileName
}

function install_helm {
	tag="v3.14.3"
	fileName="helm-$tag-linux-amd64.tar.gz"
	curl -sLO https://get.helm.sh/$fileName
	tar -zxf $fileName
	sudo mv ./linux-amd64/helm /usr/local/bin/
	rm -rf ./linux-amd64
	rm $fileName
}

function install_k9s {
	tag="v0.32.4"
	fileName="k9s_Linux_amd64.tar.gz"
	curl -sLO https://github.com/derailed/k9s/releases/download/$tag/$fileName
	sudo tar -zxf $fileName -C /usr/local/bin
	rm $fileName
}

function install_kubectl {
	tag="v1.28.7"
	fileName="kubectl"
	curl -sLO https://dl.k8s.io/release/$tag/bin/linux/amd64/$fileName
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/$fileName
	rm $fileName
}

function config_nerdfonts {
	tag="v3.2.0"
	fontDir="/usr/local/share/fonts"
	fonts=("Hack")
	for font in "${fonts[@]}"; do
		if [ ! -f $fontDir/${font}NerdFont-Regular.ttf ]; then
			echo "$font not found! installing ..."
			curl -sLO https://github.com/ryanoasis/nerd-fonts/releases/download/$tag/$font.zip
			sudo unzip -qo $font.zip -d $fontDir
			rm $font.zip
		fi
	done
	fc-cache -f
}

function install_nvim {
	tag="v0.9.5"
	fileName="nvim-linux64"
	curl -sLO https://github.com/neovim/neovim/releases/download/$tag/$fileName.tar.gz
	sudo tar -zxf $fileName.tar.gz -C /opt
	sudo ln -s /opt/$fileName/bin/nvim /usr/local/bin/nvim
	rm $fileName.tar.gz
}

function config_nvim {
	destDir="$HOME/.config/nvim"
	rm -rf $HOME/.local/share/nvim
	rm -rf $HOME/.local/state/nvim
	rm -rf $destDir
	cp -rf ./nvim $destDir
}

function install_nvm {
	tag="v0.39.7"
	nvm="$HOME/.config/nvm/nvm.sh"
	if [ ! -f $nvm ]; then
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$tag/install.sh | bash
	fi
}

function config_tmux {
	cfgDir=$HOME/.config/tmux
	mkdir -p $cfgDir
	cp ./tmux/tmux.conf $cfgDir/tmux.conf
}

function config_tpm {
	tag="3.1.0"
	pluginDir="$HOME/.tmux/plugins"
	if [ ! -d $pluginDir/tpm ]; then
		curl -sLO https://github.com/tmux-plugins/tpm/archive/refs/tags/v$tag.tar.gz
		tar -zxf v$tag.tar.gz -C $pluginDir
		mv $pluginDir/tpm-$tag $pluginDir/tpm
		rm v$tag.tar.gz
	fi
}

function config_vim {
	cp ./vim/vimrc $HOME/.vimrc
}

function install_virtualenv {
	venvName="venv"
	sudo pip -q install virtualenv
	virtualenv -q $venvName
}

function installProgs {
	progs=(alacritty btop go helm k9s kubectl nvim nvm virtualenv)
	for prog in "${progs[@]}"; do
		echo "checking $prog ..."
		if ! command -v $prog &>/dev/null; then
			echo "$prog not found! Installing ..."
			install_$prog
		fi
		echo "$prog is ready!"
	done
}

function configProgs {
	progs=(alacritty nerdfonts tmux tpm vim)
	for prog in "${progs[@]}"; do
		echo "configuring $prog ..."
		config_$prog
		echo "$prog has configured!"
	done
}

function updateBashrc {
	cp -f ./bashrc $HOME/.bashrc
	echo "bashrc has been updated!"
}

essentials
installProgs
configProgs
updateBashrc

exit 0
