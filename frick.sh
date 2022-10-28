#!/bin/sh

umount -R /mnt
rm -r /mnt/*
cryptsetup close root
cryptsetup close home
