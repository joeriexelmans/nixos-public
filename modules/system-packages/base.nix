{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    vimPlugins.vim-nix
    git
    gnupg
    apg # secure password generator
    zip
    unrar
    lf
    tree
    unzip
    killall
    dig # DNS debugging

    firefox

    gnome-calculator
    gnome-disk-utility

    nix-index
    nix-tree # really useful package for searching, figuring out why something's a dependency, etc.

    alacritty
  ];
}
