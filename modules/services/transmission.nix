{ config, pkgs, transmissionHost, basicAuth, ... }:
{
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
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

  services.nginx = {
    virtualHosts.${transmissionHost} = {
      locations."/transmission/web/" = {
        basicAuth = basicAuth;
        proxyPass = "http://127.0.0.1:9091/transmission/web/";
        proxyWebsockets = true;
      };
      locations."/transmission/rpc" = {
        basicAuth = basicAuth;
        proxyPass = "http://127.0.0.1:9091/transmission/rpc";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      51413
    ];
    allowedUDPPorts = [
      51413
    ];
  };
}
