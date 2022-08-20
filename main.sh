#!/usr/bin/env bash

pacman -S --needed --noconfirm zsh

exec ./setup.zsh
