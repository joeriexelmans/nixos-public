{ config, fileserverHost, basicAuth, ... }:
{
  services.nginx = {
    virtualHosts.${fileserverHost} = {
      root = "/schijf";

      locations."/" = {
        extraConfig = ''
          autoindex off;
        '';
      };

      locations."/downloads" = {
        basicAuth = basicAuth;
        extraConfig = ''
          autoindex on;
        '';
      }
    };
  };
}