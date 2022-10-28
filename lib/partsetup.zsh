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

mm_uefi=($(mm "$1"))
mm_root=($(mm "$2"))
mm_home=($(mm "$3"))

echo "==> Configuring partitions:"

echo "===> Setting PARTLABELs:"
parted /dev/block/$mm_uefi[1]:0 name $mm_uefi[2] LINUX-UEFI
parted /dev/block/$mm_root[1]:0 name $mm_root[2] LINUX-ROOT
parted /dev/block/$mm_home[1]:0 name $mm_home[2] LINUX-HOME

echo "===> Setting UEFI partition type to EFI System Partition"
parted /dev/block/$mm_uefi[1]:0 set $mm_uefi[2] esp on

echo "===> Creating FAT32 partition for $1:"
mkfs.fat -F32 -n LINUX-UEFI "$1"

echo "===> Creating LUKS container 'root' for $2:"
cryptsetup luksFormat --label LINUX-ROOT "$2" -q <<< "$PASS"
cryptsetup open "$2" root <<< "$PASS"
mkfs.btrfs --label LINUX-ROOT-DECRYPT /dev/mapper/root

echo "===> Creating LUKS container 'home' for $3:"
cryptsetup luksFormat --label LINUX-HOME "$3" -q <<< "$PASS"
cryptsetup open "$3" home <<< "$PASS"
mkfs.btrfs --label LINUX-HOME-DECRYPT /dev/mapper/home

echo "==> Mounting and creating subvolumes:"

echo "===> Mounting and configuring $2 (root):"
mount /dev/mapper/root /mnt -o compress=zstd:1
for i in @ @varlog @varcache
do
    btrfs subvolume create /mnt/$i
done
umount /mnt
mount /dev/mapper/root /mnt -o compress=zstd:1,subvol=@

echo "===> Creating necessary folders:"
mkdir -p /mnt/boot/efi
mkdir -p /mnt/home
mkdir -p /mnt/var/{log,cache}

echo "===> Mounting root subvolumes:"
mount /dev/mapper/root /mnt/var/log -o compress=zstd:1,subvol=@varlog
mount /dev/mapper/root /mnt/var/cache -o compress=zstd:1,subvol=@varcache

echo "===> Mounting $1 (uefi):"
mount "$1" /mnt/boot/efi

echo "===> Mounting $3 (home):"
mount /dev/mapper/home /mnt/home -o compress=zstd:1
btrfs subvolume create /mnt/home/@home
umount /mnt/home
mount /dev/mapper/home /mnt/home -o compress=zstd:1,subvol=@home

echo "Complete!"
