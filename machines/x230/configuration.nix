# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ../../modules/desktop.nix
      ../../modules/config/touchpad.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  time.timeZone = "Europe/Brussels";
  #time.timeZone = "Europe/Lisbon";
  #time.timeZone = "Europe/London";
  #time.timeZone = "America/Montreal";
  #time.timeZone = "America/Barbados";

  networking.hostName = "x230";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  hardware.logitech.wireless.enable = true;
  hardware.opentabletdriver.enable = true;
  hardware.bluetooth.enable = true;

  # ??
  # programs.gnupg.agent = {
  #   enable = true;
  #   #enableSSHSupport = true;
  #   #pinentryPackage = lib.mkForce pkgs.pinentry-qt;
  # };

  # Extra fonts to install
  fonts.packages = with pkgs; [
    aileron
    liberation_ttf
    roboto
    roboto-mono
    vista-fonts
    dejavu_fonts
    freefont_ttf
    gyre-fonts # TrueType substitutes for standard PostScript fonts
    unifont
    noto-fonts-color-emoji
  ];

  services.locate.enable = true;

  services.flatpak.enable = true;

  # Thinkpad power management
  services.power-profiles-daemon.enable = false; # conflicts with tlp
  services.tlp.enable = true;
  services.tlp.settings = {
    # Auto-disable wireless networks when Ethernet is connected.
    # Not to save power, but to get best performance.

    # Seem broken with iwd:
    # DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
    # DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi wwan";

    START_CHARGE_THRESH_BAT0 = 99; # Battery percentage to start charging
    STOP_CHARGE_THRESH_BAT0 = 100; # Battery percentage to stop charging
  };

  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.hplip # HP LaserJet 4250
    pkgs.gutenprint
    pkgs.gutenprintBin
  ];

  # GNOME
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true; 

  # firmware updates
  services.fwupd.enable = true;

  environment.systemPackages = [
    pkgs.solaar
  ];

  environment.sessionVariables =  {
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
    GTK_OVERLAY_SCROLLING = 0;
  };

  # don't wakeup from suspend from USB (e.g., mouse move)
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTR{power/wakeup}="disabled"
  '';
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
