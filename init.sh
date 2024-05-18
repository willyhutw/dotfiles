#!/usr/bin/env bash

set -u

function essentials {
	sudo apt update -qq &&
		sudo DEBIAN_FRONTEND=noninteractive apt install -qqy \
			git \
			tmux \
			curl \
			python3-pip \
			acpi \
			lm-sensors \
			sysstat \
			xsel \
			ripgrep \
			fd-find \
			fontconfig \
			unzip
}

function install_alacritty {
	# https://github.com/alacritty/alacritty/blob/master/INSTALL.md
	sudo DEBIAN_FRONTEND=noninteractive apt install -qqy \
		cmake \
		pkg-config \
		libfreetype6-dev \
		libfontconfig1-dev \
		libxcb-xfixes0-dev \
		libxkbcommon-dev \
		python3 \
		gzip \
		scdoc

	local tag="v0.13.2"
	git clone --depth 1 --branch ${tag} https://github.com/alacritty/alacritty.git alacritty_source
	cd alacritty_source

	cargo build --release
	# cargo build --release --no-default-features --features=x11
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
	rm -rf alacritty_source
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

function install_argocd {
	local tag="v2.10.6"
	local prog="/usr/local/bin/argocd"
	sudo curl -sSLf -o ${prog} https://github.com/argoproj/argo-cd/releases/download/${tag}/argocd-linux-amd64
	sudo chmod +x ${prog}
}

function install_btop {
	local tag="v1.3.2"
	local prog="btop"
	local fileName="btop-i686-linux-musl.tbz"
	curl -LO https://github.com/aristocratos/btop/releases/download/${tag}/${fileName}
	tar -xf ${fileName}
	cd ${prog}
	sudo ./install.sh
	cd ..
	rm -rf ${prog}
	rm ${fileName}
}

function install_go {
	local fileName="go1.22.2.linux-amd64.tar.gz"
	local destDir="/usr/local"
	curl -LO https://go.dev/dl/${fileName}
	sudo rm -rf ${destDir}/go && sudo tar -C ${destDir} -xzf ${fileName}
	sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
	rm ./${fileName}
	export PATH=$PATH:/usr/local/go/bin
}

function install_helm {
	local tag="v3.14.3"
	local fileName="helm-${tag}-linux-amd64.tar.gz"
	curl -LO https://get.helm.sh/${fileName}
	tar -zxf ${fileName}
	sudo mv ./linux-amd64/helm /usr/local/bin/
	rm -rf ./linux-amd64
	rm ${fileName}
}

function install_k9s {
	local tag="v0.32.4"
	local fileName="k9s_Linux_amd64.tar.gz"
	curl -LO https://github.com/derailed/k9s/releases/download/${tag}/${fileName}
	sudo tar -zxf ${fileName} -C /usr/local/bin
	rm ${fileName}
}

function install_kubectl {
	local tag="v1.28.7"
	local fileName="kubectl"
	curl -LO https://dl.k8s.io/release/${tag}/bin/linux/amd64/${fileName}
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/${fileName}
	rm ${fileName}
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

function install_nvim {
	local tag="v0.9.5"
	local fileName="nvim-linux64"
	curl -LO https://github.com/neovim/neovim/releases/download/${tag}/${fileName}.tar.gz
	sudo tar -zxf ${fileName}.tar.gz -C /opt
	sudo ln -s /opt/${fileName}/bin/nvim /usr/local/bin/nvim
	rm ${fileName}.tar.gz
}

function config_nvim {
	local destDir="${HOME}/.config/nvim"
	if [ ! -d ${destDir} ]; then
		mkdir -p ${destDir}
		cp -rf nvim/* ${destDir}/
	fi
}

function install_nvm {
	local tag="v0.39.7"
	local nvm=${HOME}/.nvm/nvm.sh
	if [ ! -f ${nvm} ]; then
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${tag}/install.sh | bash
	fi
	. ${nvm}
	nvm install --lts
}

function install_rust {
	local rust="${HOME}/.cargo/env"
	if [ -f ${rust} ]; then
		. ${rust}
	else
		curl -Sf https://sh.rustup.rs | sh -s -- -y
		. ${rust}
		rustup override set stable
		rustup update stable
	fi
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

function config_vim {
	cp vim/vimrc ${HOME}/.vimrc
}

function install_virtualenv {
	sudo pip -q install virtualenv --break-system-packages
	virtualenv -q ${HOME}/venv
	source ${HOME}/venv/bin/activate
}

function installProgs {
	local progs=(rust argocd btop go helm k9s kubectl nvim nvm virtualenv)
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
	local progs=(nerdfonts nvim tmux tpm)
	for prog in "${progs[@]}"; do
		echo "configuring ${prog} ..."
		config_${prog}
		echo "${prog} has configured!"
	done
}

function alacritty {
	echo "checking alacritty ..."
	if command -v alacritty &>/dev/null; then
		echo "alacritty not found! Installing ..."
		install_alacritty
	fi
	echo "configuring alacritty ..."
	config_alacritty
	echo "alacritty is ready!"
}

function installFormatters {
	# gofumpt, goimports-reviser
	go install mvdan.cc/gofumpt@latest
	go install github.com/incu6us/goimports-reviser/v3@latest

	# prettier
	npm install --global --force prettier

	# stylua
	curl -LO https://github.com/JohnnyMorganz/StyLua/releases/download/v0.20.0/stylua-linux-x86_64.zip
	sudo unzip -o stylua-linux-x86_64.zip -d /usr/local/bin/
	rm -f stylua-linux-x86_64.zip

	# shfmt
	sudo curl -sSLf -o /usr/local/bin/shfmt https://github.com/mvdan/sh/releases/download/v3.8.0/shfmt_v3.8.0_linux_amd64
	sudo chmod +x /usr/local/bin/shfmt

	# yamlfmt
	curl -LO https://github.com/google/yamlfmt/releases/download/v0.11.0/yamlfmt_0.11.0_Linux_x86_64.tar.gz
	sudo tar -zxf yamlfmt_0.11.0_Linux_x86_64.tar.gz -C /usr/local/bin
	rm -f yamlfmt_0.11.0_Linux_x86_64.tar.gz

	# python - black
	pip install black
}

function updateBashrc {
	# bash_completion
	mkdir -p ${HOME}/.bash_completion
	cp bash_completion/* ${HOME}/.bash_completion/

	# bash_alias
	cp bash_aliases ${HOME}/.bash_aliases

	# bashrc
	cp bashrc ${HOME}/.bashrc
	echo "bashrc has been updated!"
}

function podman {
	echo "checking podman ..."
	if command -v podman &>/dev/null; then
		echo "podman not found! Installing..."
		sudo DEBIAN_FRONTEND=noninteractive apt install -qqy \
			btrfs-progs \
			go-md2man \
			iptables \
			libassuan-dev \
			libbtrfs-dev \
			libc6-dev \
			libdevmapper-dev \
			libglib2.0-dev \
			libgpgme-dev \
			libgpg-error-dev \
			libprotobuf-dev \
			libprotobuf-c-dev \
			libseccomp-dev \
			libselinux1-dev \
			libsystemd-dev \
			pkg-config \
			uidmap \
			containernetworking-plugins \
			slirp4netns \
			fuse-overlayfs

		# config
		sudo mkdir -p /etc/containers
		sudo curl -L -o /etc/containers/registries.conf https://src.fedoraproject.org/rpms/containers-common/raw/main/f/registries.conf
		sudo curl -L -o /etc/containers/policy.json https://src.fedoraproject.org/rpms/containers-common/raw/main/f/default-policy.json

		# runc
		sudo curl -sSLf -o /usr/local/sbin/runc https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64
		sudo chmod +x /usr/local/sbin/runc

		# conmon
		local conmonTag="v2.1.11"
		git clone --depth 1 --branch ${conmonTag} https://github.com/containers/conmon.git
		cd conmon
		make
		sudo make podman
		cd ..

		# podman
		local podmanTag="v4.9.4"
		git clone --depth 1 --branch ${podmanTag} https://github.com/containers/podman.git
		cd podman
		make BUILDTAGS="seccomp"
		sudo make install
		cd ..
	fi
	echo "podman is ready!"
}

essentials
installProgs
configProgs
installFormatters
updateBashrc
# podman
# alacritty

exit 0
