# Example configuration:
#  mtlAasHost: deemz.org
#  mtlAasBaseUrl: /apis/mtl-aas/

{ config, pkgs, mtlAasHost, mtlAasBaseUrl, ... }:
{
  # reverse proxy
  services.nginx = {
    enable = true;

    virtualHosts.${mtlAasHost} = {
      locations."${mtlAasBaseUrl}/" = {
        proxyPass = "http://127.0.0.1:15478/";
        extraConfig = ''
          charset UTF-8;
          more_set_headers 'Server: NIXOS';
        '';
      };

      serverName = mtlAasHost;
    };
  };

  # run MTL-aas as a systemd service
  systemd.services.mtl-aas = {
    script = ''
      ${mtl-aas}/bin/run_server
    '';
    serviceConfig = {
      Type = "exec";
      User = "mtl-aas";
    };
  };
  users.users.mtl-aas = {
    isSystemUser = true;
    group = "mtl-aas";
  };
  users.groups.mtl-aas = {};
}
