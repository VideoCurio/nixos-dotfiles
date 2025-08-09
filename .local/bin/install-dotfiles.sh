#!/usr/bin/env bash

# This script install the dotfiles from https://github.com/VideoCurio/nixos-dotfiles
# Made for Linux and a COSMIC desktop environment.
# git required.

set -eu

available() { command -v "$1" >/dev/null; }

if ! available git; then
  printf "\e[31mgit command not found! \e[0m \n"
  exit 2
fi

GIT_PATH=$(which git)
if [ ! -x "$GIT_PATH" ]; then
  printf "\e[31mgit executable filepath error! \e[0m \n"
  exit 2
fi

if [ ! -d "$HOME" ]; then
  printf "\e[31mHOME directory not found! \e[0m \n"
  exit 2
fi

alias dotfiles='$GIT_PATH --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
echo ".dotfiles/" >> "$HOME"/.gitignore
$GIT_PATH clone --bare https://github.com/VideoCurio/nixos-dotfiles "$HOME"/.dotfiles/
dotfiles checkout || true
dotfiles config --local status.showUntrackedFiles no
dotfiles reset --hard
dotfiles pull
dotfiles status
