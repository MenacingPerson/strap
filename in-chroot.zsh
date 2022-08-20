#!/usr/bin/env zsh

. ./common.zsh

pacman -S fzf sway firefox --noconfirm

read -rsk 1

ln -sf /usr/share/zoneinfo/"$(cd /usr/share/zoneinfo; fzf)" /etc/localtime
hwclock --systohc

echo arch > /etc/hostname

echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen

bootctl install
mkinitcpio -P -c $dir/mkinitcpio
sbctl bundle -c ./cmd /boot/efi/EFI/Linux/arch.efi

useradd -mG wheel arch
passwd arch
passwd

echo 'Defaults passwd_timeout=0
Defaults pwfeedback
%wheel ALL=(ALL:ALL) ALL
Defaults insults' > /etc/sudoers.d/custom

echo "Do more setup now..."

exec zsh
