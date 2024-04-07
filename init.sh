#! /usr/bin/env bash

set -u

function essentials {
	sudo apt update -qq &&
		sudo apt install -qqy \
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

function install_alacritty {
	# https://github.com/alacritty/alacritty/blob/master/INSTALL.md
	sudo apt install -qqy \
		cmake \
		pkg-config \
		libfreetype6-dev \
		libfontconfig1-dev \
		libxcb-xfixes0-dev \
		libxkbcommon-dev \
		python3 \
		gzip \
		scdoc

	tag="v0.13.2"
	git clone --depth 1 --branch $tag https://github.com/alacritty/alacritty.git
	cd alacritty

	# cargo build --release
	cargo build --release --no-default-features --features=x11
	# cargo build --release --no-default-features --features=wayland

	sudo tic -xe alacritty,alacritty-direct extra/alacritty.info

	sudo cp target/release/alacritty /usr/local/bin
	sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
	sudo desktop-file-install extra/linux/Alacritty.desktop
	sudo update-desktop-database

	sudo mkdir -p /usr/local/share/man/man1
	scdoc <extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz >/dev/null
	scdoc <extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz >/dev/null
	sudo mkdir -p /usr/local/share/man/man5
	scdoc <extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz >/dev/null
	scdoc <extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz >/dev/null

	cd ..
	rm -rf alacritty
}

function config_alacritty {
	prog="alacritty"
	cfgDir=$HOME/.config/$prog
	mkdir -p $cfgDir/themes
	cp $prog/$prog.toml $cfgDir
	themes=("tokyonight_night" "gruvbox_dark")
	for theme in "${themes[@]}"; do
		cp $prog/themes/$theme.toml $cfgDir/themes
	done
	cp -rf bash_completion $HOME/.bash_completion
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
	cp -rf nvim $destDir
}

function install_nvm {
	tag="v0.39.7"
	nvm="$HOME/.config/nvm/nvm.sh"
	if [ ! -f $nvm ]; then
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$tag/install.sh | bash
	fi
}

function install_rust {
	rust="$HOME/.cargo/env"
	if [ -f $rust ]; then
		. $HOME/.cargo/env
	else
		curl -sSf https://sh.rustup.rs | sh -s -- -y
		. $HOME/.cargo/env
		rustup override set stable
		rustup update stable
	fi
}

function config_tmux {
	cfgDir=$HOME/.config/tmux
	mkdir -p $cfgDir/themes
	cp tmux/tmux.conf $cfgDir
	themes=("tokyonight_night" "gruvbox_dark")
	for theme in "${themes[@]}"; do
		cp tmux/themes/$theme.tmux $cfgDir/themes
	done
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
	cp vim/vimrc $HOME/.vimrc
}

function install_virtualenv {
	sudo pip -q install virtualenv
	virtualenv -q $HOME/venv
}

function installProgs {
	progs=(rust alacritty btop go helm k9s kubectl nvim nvm virtualenv)
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
	progs=(alacritty nerdfonts nvim tmux tpm)
	for prog in "${progs[@]}"; do
		echo "configuring $prog ..."
		config_$prog
		echo "$prog has configured!"
	done
}

function updateBashrc {
	cp bashrc $HOME/.bashrc
	echo "bashrc has been updated!"
}

essentials
installProgs
configProgs
updateBashrc

# TODO:: Install formatters
# https://github.com/mvdan/sh/releases/tag/v3.8.0
# https://github.com/JohnnyMorganz/StyLua/releases/tag/v0.20.0
# npm install -g prettier

# TODO:: Try LSP & completion nvim plugins.

exit 0
