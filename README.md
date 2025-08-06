# My NixOS + COSMIC dotfiles
This is my configurations files to set up a [COSMIC dekstop environment](https://system76.com/cosmic/) to my liking. It assumes to run on a NixOS Linux distribution set-up as [my NixOS-configuration](https://github.com/VideoCurio/nixos-configuration).
![NixOS COSMIC screenshot](https://github.com/VideoCurio/nixos-configuration/blob/master/img/Screenshot3.png?raw=true "NixOS with COSMIC DE")

## Installation

Install with one command:
```bash
curl -fsSL https://raw.githubusercontent.com/VideoCurio/nixos-dotfiles/refs/heads/main/.local/bin/install-dotfiles.sh | sh
```
COSMIC changes should be seen immediately, relaunch your Alacritty terminal to see the new theme.

You can use regular git command to update your dotfiles:
```bash
dotfiles status
dotfiles pull
``` 

## Features:
 **TBD**

## Development notes
Initial set-up:
```bash
git init --bare $HOME/.dotfiles
echo ".dotfiles/" >> $HOME/.gitignore
echo ".config/cosmic/com.system76.CosmicComp/v1/xkb_config" >> $HOME/.gitignore
echo "alias dotfiles='/run/current-system/sw/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.zshrc
source $HOME/.zshrc
dotfiles config --local status.showUntrackedFiles no
dotfiles status
dotfiles add .zshrc
dotfiles add ~/.config/alacritty/
dotfiles add ~/.config/cosmic/
dotfiles commit -a -m "Initial release"
dotfiles branch -M main
dotfiles remote add origin git@github.com:VideoCurio/nixos-dotfiles.git
dotfiles push -u origin main
```