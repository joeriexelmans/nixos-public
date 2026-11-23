# Edit this configuration file to define what should be installed on your 
# system. Help is available in the configuration.nix(5) man page, on 
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{ imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ../../modules/desktop.nix
      ../../modules/config/eduroam.nix
    ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true; 
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "x13"; # Define your hostname.
  # networking.wireless.enable = true; # Enables wireless support via 
  # wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Brussels";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  services.fwupd.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true; 
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true; 
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; 
    pulse.enable = true;
    jack.enable = true;
  };

  services.locate.enable = true;
  services.flatpak.enable = true;

  networking.firewall.enable = false;

  # don't wakeup from suspend from USB (e.g., mouse move)
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTR{power/wakeup}="disabled"
  '';
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];


  # This option defines the first version of NixOS you have installed on 
  # this particular machine, and is used to maintain compatibility with 
  # application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for 
  # any reason, even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are 
  # pulled from, so changing it will NOT upgrade your system - see 
  # https://nixos.org/manual/nixos/stable/#sec-upgrading for how to actually 
  # do that.
  #
  # This value being lower than the current NixOS release does NOT mean your 
  # system is out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the 
  # changes it would make to your configuration, and migrated your data 
  # accordingly.
  #
  # For more information, see `man configuration.nix` or 
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
