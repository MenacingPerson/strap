#!/usr/bin/env zsh

set -e

dir=$(dirname $(realpath $0))
cd $dir

function ask {
    local ans
    read -rsk1 "?$1 [Y/N]: " ans
    if ! [[ $ans =~ "[Yy]" || $ans = $'\n' ]]
    then
        return 1
    fi
    echo
}

function ins {
    pacman -S --needed --noconfirm $@
}
