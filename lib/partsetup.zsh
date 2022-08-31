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

echo "Setting up partitions..."
if [[ $# != 3 ]]
then
    echo 'Layout must be the following:
          $1: Boot partition (LINUX-UEFI, /boot/efi)
          $2: Root partition (LINUX-ROOT, /)
          $3: Home partition (LINUX-HOME, /home)'
    exit 1
fi

for i in $@
do
    if [[ ! -b $i ]]
    then
        echo "$i is not a valid block device!"
        exit 1
    fi
done

echo "==> Creating FAT32 partition for $1:"
mkfs.fat -F32 -n LINUX-UEFI "$1"

echo "==> Creating LUKS container 'root' for $2:"
cryptsetup luksFormat --label LINUX-ROOT "$2"
cryptsetup open "$2" root
mkfs.btrfs --label LINUX-ROOT-DECRYPT /dev/mapper/root

echo "==> Creating LUKS container 'home' for $3:"
cryptsetup luksFormat --label LINUX-HOME "$3"
cryptsetup open "$3" home
mkfs.btrfs --label LINUX-HOME-DECRYPT /dev/mapper/home

echo "==> Mounting and creating subvolumes:"

mount /dev/mapper/root /mnt -o compress=zstd:1,noatime

for i in @ @varlog @varcache
do
    btrfs subvolume create /mnt/$i
done

umount /mnt
mount /dev/mapper/root /mnt -o compress=zstd:1,subvol=@,noatime

mkdir -p /mnt/{boot/efi,home,var/{log,cache}}

mount /dev/mapper/root /mnt/var/log -o compress=zstd:1,subvol=@varlog,noatime
mount /dev/mapper/root /mnt/var/cache -o compress=zstd:1,subvol=@varcache,noatime

mount "$1" /mnt/boot/efi -o noatime

mount /dev/mapper/home /mnt/home -o compress=zstd:1,noatime
btrfs subvolume create /mnt/home/@home
umount /mnt/home
mount /dev/mapper/home /mnt/home -o compress=zstd:1,subvol=@home,noatime

echo "Complete!"
