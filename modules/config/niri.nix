{ config, pkgs, ... }:
{
  programs.niri.enable = true;
  # programs.waybar.enable = true; # top bar

  security.polkit.enable = true; # polkit
  services.gnome.gnome-keyring.enable = true; # secret service
  security.pam.services.swaylock = {};

  environment.systemPackages = with pkgs; [
    alacritty
    fuzzel
    swaylock
    mako
    swayidle
    brightnessctl
    xwayland-satellite
    kanshi # auto switch between monitor profiles (e.g., disable laptop screen when plugging in dock)
    wdisplays
  ];
}
