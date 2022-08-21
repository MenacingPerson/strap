#!/usr/bin/env zsh

set -e

dir=$(dirname $(realpath $0))
cd $dir

function ask {
    read -rqs "?$1 [Y/N]: "
    x=$?
    echo
    return $x
}

function ins {
    pacman -S --needed --noconfirm $@
}
