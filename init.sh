#! /usr/bin/env bash

set -u

function check_pkgs {
    sudo apt update \
    && sudo apt install -y \
        vim \
        git \
        tmux \
        curl \
        python3-pip \
        xsel \
        acpi \
        sysstat \
        lm-sensors
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

function copy_alacritty_conf {
    echo "copying alacritty config ..."
    conf_path=$HOME/.config/alacritty
    mkdir -p $conf_path
    cp alacritty.toml $conf_path/alacritty.toml
    echo "alacritty config has been updated!"
}

function setup_tpm {
    tag="3.1.0"
    url="https://github.com/tmux-plugins/tpm/archive/refs/tags/v$tag.tar.gz"
    path="$HOME/.tmux/plugins"
    echo "checking tpm ..."
    if [ ! -d $path/tpm ]; then
        echo "installing tpm ..."
        curl -sLO $url
	tar -zxf v$tag.tar.gz -C $path
	mv $path/tpm-$tag $path/tpm
	rm v$tag.tar.gz
    fi
    echo "tpm is ready!"
}

function copy_tmux_conf {
    echo "copying tmux config ..."
    conf_path=$HOME/.config/tmux
    mkdir -p $conf_path
    cp tmux.conf $conf_path/tmux.conf
    echo "tmux config has been updated!"
}

function copy_vimrc {
    echo "copying vim config ..."
    cp vimrc $HOME/.vimrc
    echo "vim config has been updated!"
}

function setup_nodejs {
    echo "installing nodejs ..."
    tag="v0.39.7"
    curl -sLO https://raw.githubusercontent.com/nvm-sh/nvm/$tag/install.sh
    chmod +x install.sh
    ./install.sh
    export NVM_DIR="$HOME/.config/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    nvm install --lts
    rm ./install.sh
    echo "nodejs is ready!"
}

check_pkgs
check_btop
check_alacritty
copy_alacritty_conf
setup_tpm
copy_tmux_conf
copy_vimrc
setup_nodejs

exit 0
