#!/usr/bin/env zsh

# SPDX-License-Identifier: GPL-3.0-or-later

. $(dirname $(realpath "$0"))/common.zsh

read -rs "?Enter a password: " PASS
echo

source ./partsetup.zsh
source ./strap.zsh
