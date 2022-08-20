#!/bin/sh

pacman -S --needed --noconfirm zsh

exec ./strap.zsh
