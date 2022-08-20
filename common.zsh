#!/usr/bin/env zsh

function ask {
    read -rqs "?$1 [Y/N]: "
    x=$?
    echo
    return $x
}
