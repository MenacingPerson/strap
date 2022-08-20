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

pacstrap /mnt base base-devel linux linux-firmware networkmanager btrfs-progs zsh sbctl
arch-chroot /mnt /usr/bin/true
echo

timedatectl set-ntp true

genfstab -U /mnt
if ! ask "Is this fstab correct?"
then
    exit 1
fi
genfstab -U /mnt >> /mnt/etc/fstab

mkdir -p /mnt/strap
cp -r . /mnt/strap
arch-chroot /mnt /strap/in-chroot.zsh
