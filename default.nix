{ pkgs ? import <nixpkgs> {} }:
pkgs.callPackage ./pkgs/curios-dotfiles {}

# test it locally with:
# nix-build && nix-env -i -f default.nix
