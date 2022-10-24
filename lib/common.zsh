#!/usr/bin/env zsh

# SPDX-License-Identifier: GPL-3.0-or-later

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

function mm {
    lsblk "$1" -no MAJ:MIN | sed 's/:/ /g'
}

function ins {
    pacman -S --needed --noconfirm $@
}
