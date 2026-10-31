{ config, pkgs, ... }:
let
  commonConfig = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      charset UTF-8;
      disable_symlinks off;
      more_set_headers 'Server: NIXOS';
      more_set_headers 'Access-Control-Allow-Origin: *';
    '' + (builtins.readFile ../../assets/nginx-block-ai-bots.conf);
  };
  goaccess = (pkgs.goaccess.override {
    withGeolocation = true;
  });
in
{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # virtualHosts."mstro.duckdns.org" = {
    #   serverName = "mstro.duckdns.org";
    # } // commonConfig;
    virtualHosts."deemz.org" = {
      serverName = "deemz.org";
    } // commonConfig;

    virtualHosts."joeri-exelmans.page" = {
      serverName = "joeri-exelmans.page";
    } // commonConfig;
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      # "mstro.duckdns.org".email = "joeri.exelmans@gmail.com";
      "deemz.org".email = "joeri.exelmans@gmail.com";
      "joeri-exelmans.page".email = "joeri.exelmans@gmail.com";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
  };

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
    script = "${pkgs.gzip}/bin/zcat /var/log/nginx/access.log.*.gz | ${goaccess}/bin/goaccess -a -o /var/log/nginx/goaccess.html --log-format=COMBINED --geoip-database=${../../assets/GeoLite2-City.mmdb} --geoip-database=${../../assets/GeoLite2-Country.mmdb} --geoip-database=${../../assets/GeoLite2-ASN.mmdb}  /var/log/nginx/access.log /var/log/nginx/access.log.1 -";
    serviceConfig = {
      Type = "oneshot";
      User = "nginx";
      Nice = 19; # low priority
      IOSchedulingClass = "idle";
    };
  };
}
