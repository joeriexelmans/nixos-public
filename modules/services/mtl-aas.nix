# Example configuration:
#  mtlAasHost: deemz.org
#  mtlAasBaseUrl: /apis/mtl-aas/

{ config, pkgs, mtl-aas, mtlAasHost, mtlAasBaseUrl, ... }:
{
  # create user
  users.users.mtl-aas = {
    isSystemUser = true;
    group = "mtl-aas";
  };
  users.groups.mtl-aas = {};

  # run MTL-aas as a systemd service
  systemd.services.mtl-aas = {
    script = ''
      ${mtl-aas}/bin/run_gunicorn
    '';
    serviceConfig = {
      Type = "exec";
      User = "mtl-aas";
    };
    enable = true;
  };

  # serve behind reverse proxy
  services.nginx = {
    virtualHosts.${mtlAasHost} = {
      locations."${mtlAasBaseUrl}/" = {
        proxyPass = "http://127.0.0.1:15478/";
      };
      serverName = mtlAasHost;
    };
  };
}
