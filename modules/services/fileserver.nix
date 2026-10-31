{ config, basicAuth, ... }:
{
  services.nginx = {
      root = "/schijf";

      locations."/" = {
        basicAuth = basicAuth;
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
  };
}