# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" # needed for Sublime Text 4
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.kernelPackages = pkgs.linuxPackages_latest; # use latest kernel - my fancy hardware wasnt supported on default kernel.

  # Example of applying a kernel patch:
  # boot.kernelPatches = [{
  #   name = "myPatch"; # name doesn't matter
  #   patch = pkgs.writeTextFile { # file will be written to /nix/store
  #     name = "myPatch.patch"; # filename doesn't matter
  #     text = ''
  #      <insert contents of patch here, inline!>
  #     '';
  #   };
  # }];

  boot.resumeDevice = "/dev/disk/by-uuid/a9a63c82-df16-4fde-a794-78ef231c59f6";
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32*1024;
    }
  ];

  # Set your time zone.
  time.timeZone = "Europe/Brussels";
  #time.timeZone = "Europe/London";
  #time.timeZone = "America/Montreal";
  #time.timeZone = "America/Barbados";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_BE.utf8";
    LC_IDENTIFICATION = "nl_BE.utf8";
    LC_MEASUREMENT = "nl_BE.utf8";
    LC_MONETARY = "nl_BE.utf8";
    LC_NAME = "nl_BE.utf8";
    LC_NUMERIC = "nl_BE.utf8";
    LC_PAPER = "nl_BE.utf8";
    LC_TELEPHONE = "nl_BE.utf8";
    LC_TIME = "nl_BE.utf8";
  };

  networking.hostName = "t14";
  networking.extraHosts = ''
    143.129.75.8 msdl-testing
  '';
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.firewall.enable = false;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    autoRepeatDelay = 150;
    xkb.layout = "us"; # keymap
    xkb.variant = ""; # ?
  };
  services.libinput.enable = true;
  services.libinput.mouse.middleEmulation = false; # middle mouse button emulation (left+right = middle)

  # T14 Gen3 trackpoint is way too sensitive by default:
  hardware.trackpoint = {
    enable = true;
    device = "TPPS/2 Elan TrackPoint";
    # sensitivity = 90;  # default: 128
    speed = 110;        # default: 97
  };
  hardware.logitech.wireless.enable = true;

  # Huion tablet:
  hardware.opentabletdriver.enable = true;

  # Sound...
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig = import ./pipewire-extra-config.nix;
  };

  # Graphics...
  hardware.graphics.enable = true; # enable OpenGL
  hardware.graphics.enable32Bit = true; # also install 32 bit drivers (in order to run 32 bit apps under Wine)
  hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver # hardware accelerated video decoding on Intel
      vaapiIntel
  ];

  hardware.bluetooth.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.maestro = {
    isNormalUser = true;
    description = "Joeri Exelmans";
    extraGroups = [ "networkmanager" "wheel" "vboxusers" "docker" "video" ];
    packages = with pkgs; [];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = lib.mkForce pkgs.pinentry-qt;
  };

  # Extra fonts to install
  fonts.packages = with pkgs; [
    aileron
    liberation_ttf
    roboto
    roboto-mono
    vistafonts
    dejavu_fonts
    freefont_ttf
    gyre-fonts # TrueType substitutes for standard PostScript fonts
    unifont
    noto-fonts-color-emoji
  ];

  # This seems to fix my buggy PC-LM1E webcam
  environment.etc."modprobe.d/uvcvideo.conf".text = pkgs.lib.mkForce ''
    options uvcvideo quirks=0x106
  '';

  # Enable experimental Wayland support in Chromium
  # Disabled, because this breaks Chromium on X11
  # nixpkgs.config.chromium.commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";

  services.pcscd.enable = true; # Belgian eID

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

  #virtualisation.virtualbox.host.enable = true;
  # Causes slow-as-fuck re-compilation of kernel module on every software update:
  #virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.docker.enable = true;

  # KDE config
  services.desktopManager.plasma6.enable = true;
  #services.xserver.desktopManager.xfce.enable = true;

  # firmware updates
  services.fwupd.enable = true;

  environment.systemPackages = import ./system-packages.nix { pkgs=pkgs; };

  environment.sessionVariables = let
    # schema = pkgs.gsettings-desktop-schemas;
    # datadir = "${schema}/share/gsettings-schemas/${schema.name}";
  in {
    # XDG_DATA_DIRS = [ "${datadir}" ]; #:$XDG_DATA_HOME";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
    GTK_OVERLAY_SCROLLING = 0;
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTR{power/wakeup}="disabled"
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
