#! /usr/bin/env bash

set -u

function check_git {
    echo "checking git ..."
    which git &>/dev/null
    if [ $? != 0 ]; then
        echo "installing git ..."
	sudo apt install -y git
    fi
    echo "git is ready!"
}

function check_tmux {
    echo "checking tmux ..."
    which tmux &>/dev/null
    if [ $? != 0 ]; then
        echo "installing tmux ..."
	sudo apt install -y tmux
    fi
    echo "tmux is ready!"
}

function check_xsel {
    echo "checking xsel ..."
    which xsel &>/dev/null
    if [ $? != 0 ]; then
        echo "installing xsel ..."
	sudo apt install -y xsel
    fi
    echo "xsel is ready!"
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
    cp .tmux.conf $conf_path/tmux.conf
    echo "tmux config has been updated!"
}


check_git
check_tmux
check_xsel
setup_tpm
copy_tmux_conf

exit 0
