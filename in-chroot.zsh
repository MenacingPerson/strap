#!/usr/bin/env zsh

. ./common.zsh

read -r "?Enter a valid locale"

pacman -S fzf sway firefox --noconfirm

ln -sf /usr/share/zoneinfo/"$(cd /usr/share/zoneinfo; fzf)" /etc/localtime
hwclock --systohc

echo arch > /etc/hostname

echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen

mkinitcpio -Pc ./mkinitcpio
mkinitcpio -c ./mkinitcpio --kernelimage /boot/vmlinuz-linux -U /boot/efi/EFI/Linux/arch.efi --cmdline ./cmd


useradd -mG wheel arch
passwd arch
passwd

echo 'Defaults passwd_timeout=0
Defaults pwfeedback
%wheel ALL=(ALL:ALL) ALL
Defaults insults' > /etc/sudoers.d/custom

bootctl install

echo "Do more setup now..."

exec zsh
