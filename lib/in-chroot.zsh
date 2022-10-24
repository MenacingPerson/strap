#!/usr/bin/env zsh

# SPDX-License-Identifier: GPL-3.0-or-later

. $(dirname $(realpath "$0"))/common.zsh

echo "====> Press enter to choose timezone now."
read -rsk 1
ln -s /usr/share/zoneinfo/"$(cd /usr/share/zoneinfo; fzf)" /etc/localtime
hwclock --systohc

locale-gen

bootctl install
mkinitcpio -P

systemctl enable NetworkManager

useradd -mG wheel arch
passwd arch <<< ${1}$'\n'${1}
passwd <<< ${1}$'\n'${1}

su arch -c "chsh -s /usr/bin/fish <<< ${1}"
chsh -s /usr/bin/fish

echo "Do more setup now..."

exec fish
