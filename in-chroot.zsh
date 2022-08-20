#!/usr/bin/env zsh

. ./common.zsh

hwclock --systohc

read -rsk 1
ln -sf /mnt/usr/share/zoneinfo/"$(cd /mnt/usr/share/zoneinfo; fzf)" /mnt/etc/localtime
locale-gen

bootctl install
mkinitcpio -P -c $dir/mkinitcpio
sbctl bundle -c ./cmd /boot/efi/EFI/Linux/arch.efi

useradd -mG wheel arch
passwd arch
passwd

echo "Do more setup now..."

exec zsh
