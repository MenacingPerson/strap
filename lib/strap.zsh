#!/usr/bin/env zsh

# SPDX-License-Identifier: GPL-3.0-or-later

. $(dirname $(realpath "$0"))/common.zsh

echo "Please assure the following:
1. UEFI mode is on
2. Secure boot is off
3. Internet connection is valid"

sleep 5

timedatectl set-ntp true

ins -y archlinux-keyring

pacstrap /mnt base base-devel linux-lts linux-firmware \
              networkmanager vim btrfs-progs zsh \
              yadm polkit grml-zsh-config git fzf

arch-chroot /mnt /usr/bin/true

genfstab -U /mnt

genfstab -U /mnt >> /mnt/etc/fstab

cp /mnt/etc/crypttab /mnt/etc/crypttab.initramfs
cat ./crypttab >> /mnt/etc/crypttab
cat ./crypttab.initramfs >> /mnt/etc/crypttab.initramfs

echo arch > /mnt/etc/hostname

echo 'en_US.UTF-8 UTF-8' >> /mnt/etc/locale.gen

cp -r ./etc /mnt

mkdir -p /mnt/strap
cp -r .. /mnt/strap
arch-chroot /mnt /strap/lib/in-chroot.zsh "$PASS"

rm -rf /mnt/strap
