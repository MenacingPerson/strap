#!/usr/bin/env zsh

. $(dirname $(realpath "$0"))/common.zsh

echo "Please assure the following:
1. UEFI mode is on
2. Secure boot is off
3. Internet connection is valid"

sleep 5

timedatectl set-ntp true

ins -y archlinux-keyring

pacstrap /mnt base base-devel linux linux-firmware networkmanager vim btrfs-progs zsh sbctl fzf sway firefox grml-zsh-config
arch-chroot /mnt /usr/bin/true

genfstab -U /mnt

if ! ask "Is this fstab correct?"
then
    exit 1
fi
genfstab -U /mnt >> /mnt/etc/fstab

cp /mnt/etc/crypttab /mnt/etc/crypttab.initramfs
cat ./crypttab >> /mnt/etc/crypttab
cat ./crypttab.initramfs >> /mnt/etc/crypttab.initramfs

echo arch > /mnt/etc/hostname

cp ./mkinitcpio /mnt/etc/mkinitcpio.conf

echo 'Defaults passwd_timeout=0
Defaults pwfeedback
%wheel ALL=(ALL:ALL) ALL
Defaults insults' > /mnt/etc/sudoers.d/custom

echo "LANG=en_US.UTF-8" > /etc/locale.conf

mkdir -p /mnt/strap
cp -r .. /mnt/strap
arch-chroot /mnt /strap/lib/in-chroot.zsh

rm -rf /mnt/strap
