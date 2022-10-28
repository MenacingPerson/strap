#!/usr/bin/env zsh

# SPDX-License-Identifier: GPL-3.0-or-later

. $(dirname $(realpath "$0"))/common.zsh

pacman-key --init
pacman-key --populate

PASS="$(systemd-ask-password)"

source ./partsetup.zsh
source ./strap.zsh
