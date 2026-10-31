{ config, navidromeHost, ... }:
{
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/schijf/downloads/music";
      BaseUrl = "/navidrome";
    };
    # environmentFile = config.sops.secrets.navidrome_env.path;
  };

  # reverse proxy
  services.nginx.virtualHosts.${navidromeHost}.locations."/navidrome" = {
    proxyPass = "http://127.0.0.1:4533/navidrome";
    proxyWebsockets = true;
    extraConfig = ''
      proxy_buffering off;
    '';
  };
}
