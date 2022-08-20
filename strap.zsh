#!/usr/bin/env zsh

. ./common.zsh

echo "Please assure the following:
1. UEFI mode is on
2. Secure boot is off
3. Internet connection is valid
4. Partitioning is complete in /mnt:
   - Root is LINUX-ROOT
   - /home is LINUX-HOME
   - /boot/efi is LINUX-BOOT"

sleep 5

timedatectl set-ntp true

pacman -Sy --needed --noconfirm archlinux-keyring

pacstrap /mnt base base-devel linux linux-firmware networkmanager btrfs-progs zsh sbctl fzf sway firefox grml-zsh-config
arch-chroot /mnt /usr/bin/true

genfstab -U /mnt

if ! ask "Is this fstab correct?"
then
    exit 1
fi
genfstab -U /mnt >> /mnt/etc/fstab

echo arch > /mnt/etc/hostname

echo 'Defaults passwd_timeout=0
Defaults pwfeedback
%wheel ALL=(ALL:ALL) ALL
Defaults insults' > /mnt/etc/sudoers.d/custom

echo "LANG=en_US.UTF-8" > /etc/locale.conf

mkdir -p /mnt/strap
cp -r . /mnt/strap
arch-chroot /mnt /strap/in-chroot.zsh

rm -rf /mnt/strap
