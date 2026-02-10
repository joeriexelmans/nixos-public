# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, sops-nix, icomidal, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      sops-nix.nixosModules.sops
    ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/maestro/.config/sops/age/keys.txt";

  sops.secrets."nginx-users" = {
    owner = "nginx";
    group = "nginx";
    sopsFile = ./secrets/nginx-users;
    format = "binary";
  };
  sops.secrets."duckdns_token" = {
    owner = "duckdns";
  };
  sops.secrets."cloudflare_api_token" = {
    owner = "cloudflare-dns";
  };
  # contains LastFM API key:
  sops.secrets."navidrome_env" = {
    owner = "navidrome";
    sopsFile = ./secrets/navidrome_env;
    format = "binary";
  };

  hardware.firmware = [
    (
      pkgs.runCommand "edid.bin" { } ''
        mkdir -p $out/lib/firmware/edid
        cp ${./nec-v462-edid-patched.bin} $out/lib/firmware/edid/edid.bin
      ''
    )
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  #boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.configurationLimit = 10;
  boot.loader.systemd-boot.enable = true;
 
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.fwupd.enable = true;

  # Enable the X11 windowing system.
  #services.xserver.enable = true;
  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.displayManager.gdm.wayland = false;
  #services.xserver.desktopManager.gnome.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.deviceSection = ''
    Option "TearFree" "true"
  '';

  services.displayManager.autoLogin = {
    enable = true;
    user= "maestro";
  };
  services.displayManager.preStart = ''
    # Enable full range of RGB values in HDMI output
    ${pkgs.libdrm.bin}/bin/proptest -M i915 -D /dev/dri/card1 95 connector 97 1
  '';
  # Workaround for GDM crashing on autologin:
  # https://github.com/NixOS/nixpkgs/issues/103746
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Run icomidal script daily
  systemd.timers.icomidal = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "icomidal.service";
    };
  };
  systemd.services.icomidal = {
    script = ''
      ${icomidal}/bin/icomidal > /var/lib/icomidal/komida.ics
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "icomidal";
    };
  };
  users.users.icomidal = {
    isSystemUser = true;
    group = "icomidal";
  };
  users.groups.icomidal = {};

  # Run goaccess script hourly
  systemd.timers.goaccess = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "goaccess.service";
    };
  };
  systemd.services.goaccess = {
    script = "${pkgs.gzip}/bin/zcat /var/log/nginx/access.log.*.gz | ${pkgs.goaccess}/bin/goaccess -a -o /var/log/nginx/goaccess.html --log-format=COMBINED --geoip-database=${./GeoLite2-City.mmdb} --geoip-database=${./GeoLite2-Country.mmdb} --geoip-database=${./GeoLite2-ASN.mmdb}  /var/log/nginx/access.log /var/log/nginx/access.log.1 -";
    serviceConfig = {
      Type = "oneshot";
      User = "nginx";
      Nice = 19; # low priority
      IOSchedulingClass = "idle";
    };
  };

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e";

  security.rtkit.enable = true;
  #services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig = import ./pipewire-extra-config.nix;
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
    intel-compute-runtime # OpenCL filter support
  ];

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;


  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    vim
    firefox
    git
    pavucontrol
    vlc
    transmission-remote-gtk
    helvum
    chromium
    kodi
    libdrm # proptest
    (goaccess.override {
      withGeolocation = true;
    })
    jq
    rygel # UPnP media renderer
  ];

  users.users.maestro = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
  };

  programs.gnupg.agent = {
    enable = true;
   # enableSSHSupport = true;
  };


  networking.hostName = "seedbox"; # Define your hostname.
  networking.domain = "deemz.org";
  networking.fqdn = "deemz.org";
  networking.useDHCP = false;
  networking.interfaces.enp1s0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.1.60";
        prefixLength = 24;
      }
    ];
    ipv6.addresses = [
      {
        address = "2a02:578:8591:1b00::ffff";
        prefixLength = 64;
      }
    ];
  };
  networking.enableIPv6 = true;
  networking.defaultGateway = "192.168.1.1";
  #networking.defaultGateway6 = {
  #  address = "fe80::52d4:f7ff:fe28:9849"; # TP-Link router
  #  interface = "enp1s0";
  #};
  networking.nameservers = [ "1.1.1.1" ];
  networking.extraHosts = ''
    192.168.1.60             mstro.duckdns.org
    192.168.1.60             deemz.org
    192.168.1.60             joeri-exelmans.page
  '';
    # 2a02:578:8591:1b00::ffff mstro.duckdns.org
  networking.networkmanager.unmanaged = [ "enp1s0" ];

  # IPv6 is enabled, meaning we're not protected by NAT -> enable firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      #53
      80
      443
      51413 # Transmission
    ];
    allowedUDPPorts = [
      #53
      51413 # Transmission
    ];
    # Accept all traffic from local network:
    extraCommands = ''
      iptables -A nixos-fw -p tcp --source 192.168.1.0/24 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --source 192.168.1.0/24 -j nixos-fw-accept
      ip6tables -A nixos-fw -p tcp --source 2A02:578:8591:1B00::/64 -j nixos-fw-accept
      ip6tables -A nixos-fw -p udp --source 2A02:578:8591:1B00::/64 -j nixos-fw-accept
    '';
  };

  # Users specifically for sending dynamic DNS updates
  users.users.duckdns = {
    isSystemUser = true;
    group = "dyndns";
  };
  users.users.cloudflare-dns = {
    isSystemUser = true;
    group = "dyndns";
  };
  users.groups.dyndns = {}; # create this user
  # Send DNS updates
  services.cron = let
    cloudflare = import ./cloudflare.nix;
  in {
    enable = true;
    systemCronJobs = [
      # Update DuckDNS - use 'journalctl -e' to see logged output (should log 'OK' every 5 minutes)
      "*/5 * * * * duckdns curl 'https://www.duckdns.org/update?domains=mstro&token=$(cat ${config.sops.secrets.duckdns_token.path})&ip=' | systemd-cat -t 'duckdns'"
    ];
  };

  systemd.timers.cloudflare-dns = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:*:00"; # every minute
      Persistent = true;
      Unit = "cloudflare-dns.service";
    };
  };
  systemd.services.cloudflare-dns = let
    cloudflare = import ./cloudflare.nix;
    command = cfg: ''
      ${pkgs.curl}/bin/curl \
        --request PUT \
        --url https://api.cloudflare.com/client/v4/zones/${cfg.zone_id}/dns_records/${cfg.dns_record_id} \
        --header 'Content-Type: application/json' \
        --header 'Authorization: Bearer ''\'''${TOKEN}''' \
        --data '{
           "comment": "Domain verification record",
           "name": "@",
           "proxied": false,
           "settings": {},
           "tags": [],
           "ttl": 60,
           "content": "''\'''${IP}'",
           "type": "A"
        }'
    '';
  in {
    script = ''
      echo "updating cloudflare DNS ..."
      TOKEN="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.cloudflare_api_token.path})"
      IP="$(${pkgs.curl}/bin/curl https://ipinfo.io/ip)"
      echo "''${TOKEN} ''${IP}"
      ${command cloudflare.homepage}
      ${command cloudflare.deemz}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "cloudflare-dns";
    };
  };

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.banner = ''
    Howdy, partner!
  '';

  # DNSMasq will override the DNS entry for /etc/hosts entries
  services.dnsmasq = {
    enable = true;
    settings = {
      server = [
        "1.1.1.1" # Cloudflare primary
        "1.0.0.1" # Cloudflare secondary
        "8.8.8.8" # Google primary
        "8.8.4.4" # Google secondary
        "2606:4700:4700::1111" # Cloudflare primary
        "2606:4700:4700::1001" # Cloudflare secondary
        "2a02:578:8000:2:212:71:0:33" # Edpnet primary
        "2a02:578:1001:3:212:71:8:10" # Edpnet secondary
      ];
      listen-address = "::1,2a02:578:8591:1b00::ffff,127.0.0.1,192.168.1.60";
      cache-size = 10000;
    };
  };

  # NGINX
  services.nginx = let
    userlistFile = config.sops.secrets."nginx-users".path;
    commonConfig = {
      root = "/schijf";

      locations."/" = {
        basicAuthFile = userlistFile;
        extraConfig = ''
          autoindex on;
          add_header Cache-Control max-age=172800;
        '';
        proxyWebsockets = true;
      };

      locations."/robots.txt" = {
        basicAuth = {};
      };
      locations."/sitemap.xml" = {
        basicAuth = {};
      };

      locations."/public" = {
        basicAuth = {};
        extraConfig = ''
          autoindex off;
        '';
      };

      locations."/plantuml" = {
        basicAuth = {};
        extraConfig = ''
          autoindex off;
        '';
        proxyPass = "http://127.0.0.1:8080/plantuml";
        proxyWebsockets = true;
      };

      locations."/transmission/web/" = {
        basicAuthFile = userlistFile;
        #basicAuth = userlist;
        proxyPass = "http://127.0.0.1:9091/transmission/web/";
        proxyWebsockets = true;
      };
      locations."/transmission/rpc" = {
        #basicAuth = userlist;
        basicAuthFile = userlistFile;
        proxyPass = "http://127.0.0.1:9091/transmission/rpc";
        proxyWebsockets = true;
      };

      locations."/navidrome" = {
        proxyPass = "http://127.0.0.1:4533/navidrome";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };

      locations."/git/" = {
        basicAuth = {};
        proxyPass = "http://127.0.0.1:27365/";
        proxyWebsockets = true;
      };

      locations."/apis/mtl-aas/" = {
        proxyPass = "http://127.0.0.1:15478/";
      };

      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        charset UTF-8;
        disable_symlinks off;
        more_set_headers 'Server: NIXOS';
        more_set_headers 'Access-Control-Allow-Origin: *';
      '' + (builtins.readFile ./nginx-block-ai-bots.conf);
    };
  in {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Access from internet: encrypted, authenticated (except '/public')
    virtualHosts."mstro.duckdns.org" = commonConfig // {
      serverName = "mstro.duckdns.org";
    };
    virtualHosts."deemz.org" = commonConfig // {
      serverName = "deemz.org";
    };
    virtualHosts."joeri-exelmans.page" = {
      serverName = "joeri-exelmans.page";
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        charset UTF-8;
        more_set_headers 'Server: NixOS';
      '';
      locations."/" = {
        root = "/schijf/public/homepage/";
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    certs = {
      "mstro.duckdns.org".email = "joeri.exelmans@gmail.com";
      "deemz.org".email = "joeri.exelmans@gmail.com";
      "joeri-exelmans.page".email = "joeri.exelmans@gmail.com";
    };
  };

  services.plantuml-server = {
    enable = true;
    plantumlLimitSize = 40000;
  };

  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/schijf/music/downloads";
      BaseUrl = "/navidrome";
    };
    environmentFile = config.sops.secrets.navidrome_env.path;
  };

  services.forgejo = {
    enable = true;
    settings.server.ROOT_URL = "https://deemz.org/git/";
    settings.server.HTTP_PORT = 27365;
    settings.service.DISABLE_REGISTRATION = true;
  };

  services.transmission = let
    # use older version of transmission because 4.0.6 is banned from PTP
    transmission_4_0_5 = (import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb.tar.gz";
      sha256 = "sha256:0ngw2shvl24swam5pzhcs9hvbwrgzsbcdlhpvzqc7nfk8lc28sp3";
    }) {inherit system;}).transmission_4;
  in {
    enable = true;
    package = transmission_4_0_5;
    settings = {
      peer-port = 51413;
      rpc-enabled = true;
      rpc-authentication-required = false;
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
    };
    home = "/schijf/transmission";
    downloadDirPermissions = "775"; # transmission: read+write+exec, other: read+exec
  };

  # UPnP media playback (local network only)
  #services.gnome.rygel.enable = true;
  services.gmediarender = {
    enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
