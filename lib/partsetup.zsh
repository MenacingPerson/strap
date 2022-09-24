#!/usr/bin/env zsh

# SPDX-License-Identifier: GPL-3.0-or-later

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
cryptsetup luksFormat --label LINUX-ROOT "$2" -q <<< "$PASS"
cryptsetup open "$2" root <<< "$PASS"
mkfs.btrfs --label LINUX-ROOT-DECRYPT /dev/mapper/root

echo "==> Creating LUKS container 'home' for $3:"
cryptsetup luksFormat --label LINUX-HOME "$3" -q <<< "$PASS"
cryptsetup open "$3" home <<< "$PASS"
mkfs.btrfs --label LINUX-HOME-DECRYPT /dev/mapper/home

echo "==> Mounting and creating subvolumes:"

mount /dev/mapper/root /mnt -o compress=zstd:1

for i in @ @varlog @varcache
do
    btrfs subvolume create /mnt/$i
done

umount /mnt
mount /dev/mapper/root /mnt -o compress=zstd:1,subvol=@

mkdir -p /mnt/{boot/efi,home,var/{log,cache}}

mount /dev/mapper/root /mnt/var/log -o compress=zstd:1,subvol=@varlog
mount /dev/mapper/root /mnt/var/cache -o compress=zstd:1,subvol=@varcache

mount "$1" /mnt/boot/efi

mount /dev/mapper/home /mnt/home -o compress=zstd:1
btrfs subvolume create /mnt/home/@home
umount /mnt/home
mount /dev/mapper/home /mnt/home -o compress=zstd:1,subvol=@home

echo "Complete!"
