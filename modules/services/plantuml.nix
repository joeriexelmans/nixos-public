{ config, plantUmlHost, ... }:
{
  services.plantuml-server = {
    enable = true;
    plantumlLimitSize = 40000;
  };

  services.nginx = {
    virtualHosts.${plantUmlHost} = {
      locations."/plantuml" = {
        basicAuth = {};
        extraConfig = ''
          autoindex off;
        '';
        proxyPass = "http://127.0.0.1:8080/plantuml";
        proxyWebsockets = true;
      };
    };
  };
}
