{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    chromium
    thunderbird
    signal-desktop
    karere
    tor-browser
    zoom-us
    transmission-remote-gtk
    transmission_4-gtk
  ];
}