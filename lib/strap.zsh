#!/usr/bin/env zsh

# strap: A simple set of scripts to set up arch
# Copyright (C) 2022 Sam

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

. $(dirname $(realpath "$0"))/common.zsh

echo "Please assure the following:
1. UEFI mode is on
2. Secure boot is off
3. Internet connection is valid"

sleep 5

timedatectl set-ntp true

ins -y archlinux-keyring

pacstrap /mnt base base-devel linux-lts linux-firmware \
              networkmanager vim btrfs-progs zsh sbctl \
              fzf sway firefox grml-zsh-config git

arch-chroot /mnt /usr/bin/true

genfstab -U /mnt

genfstab -U /mnt >> /mnt/etc/fstab

cp /mnt/etc/crypttab /mnt/etc/crypttab.initramfs
cat ./crypttab >> /mnt/etc/crypttab
cat ./crypttab.initramfs >> /mnt/etc/crypttab.initramfs

echo arch > /mnt/etc/hostname

echo en_US.UTF-8 >> /etc/locale.gen

cp ./mkinitcpio /mnt/etc/mkinitcpio.conf
cp -r ./mkinitcpio.d /mnt/etc/mkinitcpio.d

echo 'Defaults passwd_timeout=0
Defaults pwfeedback
%wheel ALL=(ALL:ALL) ALL
Defaults insults' > /mnt/etc/sudoers.d/custom

echo "LANG=en_US.UTF-8" > /etc/locale.conf

mkdir -p /mnt/strap
cp -r .. /mnt/strap
arch-chroot /mnt /strap/lib/in-chroot.zsh

rm -rf /mnt/strap
