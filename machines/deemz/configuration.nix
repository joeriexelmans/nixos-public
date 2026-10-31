# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, system ? builtins.currentSystem, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ./network.nix

      ../../modules/config/graphics.nix
      ../../modules/config/keyboard.nix
      ../../modules/config/locale.nix
      ../../modules/config/pipewire.nix
      ../../modules/config/users.nix

      ../../modules/system-packages/base.nix
      ../../modules/system-packages/communication.nix

      ../../modules/services/cloudflare.nix
      ../../modules/services/dnsmasq.nix
      ../../modules/services/fileserver.nix
      ../../modules/services/forgejo.nix
      ../../modules/services/homepage.nix
      # ../../modules/services/icomidal.nix
      # ../../modules/services/mtl-aas.nix
      ../../modules/services/navidrome.nix
      ../../modules/services/nginx.nix
      # ../../modules/services/plantuml.nix
      # ../../modules/services/refinery.nix
      ../../modules/services/sshd.nix
      ../../modules/services/transmission.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.configurationLimit = 10;
  boot.loader.systemd-boot.enable = true;
 
  time.timeZone = "Europe/Brussels";

  services.fwupd.enable = true;

  services.displayManager.gdm.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "maestro";
  };
  services.desktopManager.gnome.enable = true;

  # Workaround for GDM crashing on autologin:
  # https://github.com/NixOS/nixpkgs/issues/103746
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # programs.gnupg.agent = {
  #   enable = true;
  #  # enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
