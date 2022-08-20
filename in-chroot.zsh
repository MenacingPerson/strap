#!/usr/bin/env zsh

. $(dirname "$0")/common.zsh

hwclock --systohc

read -rsk 1
ln -sf /usr/share/zoneinfo/"$(cd /usr/share/zoneinfo; fzf)" /etc/localtime
locale-gen

bootctl install
mkinitcpio -P -c $dir/mkinitcpio
sbctl bundle -c ./cmd /boot/efi/EFI/Linux/arch.efi

useradd -mG wheel arch
passwd arch
passwd

echo "Do more setup now..."

exec zsh
