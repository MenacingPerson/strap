#!/usr/bin/env zsh

. ./common.zsh

hwclock --systohc

locale-gen

bootctl install
mkinitcpio -P -c $dir/mkinitcpio
sbctl bundle -c ./cmd /boot/efi/EFI/Linux/arch.efi

useradd -mG wheel arch
passwd arch
passwd

echo "Do more setup now..."

exec zsh
