#!/usr/bin/env zsh

. $(dirname "$0")/common.zsh

echo "Choose locale now."
read -rsk 1
ln -sf /usr/share/zoneinfo/"$(cd /usr/share/zoneinfo; fzf)" /etc/localtime
hwclock --systohc

locale-gen

bootctl install
mkinitcpio -P -c $dir/mkinitcpio
cp ./cmd /etc/kernel/cmdline
sbctl bundle -k /boot/vmlinuz-linux-lts -f /boot/initramfs-linux-lts.img -c /etc/kernel/cmdline /boot/efi/EFI/Linux/arch.efi

useradd -mG wheel arch
passwd arch
passwd

echo "Do more setup now..."

exec zsh
