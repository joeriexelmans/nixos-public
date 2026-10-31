{ config, forgejoHost, ... }:
{
  services.forgejo = {
    enable = true;
    settings.server.ROOT_URL = "https://${forgejoHost}/git/";
    settings.server.HTTP_PORT = 27365;
    settings.service.DISABLE_REGISTRATION = true;
  };

  services.nginx.virtualHosts.${forgejoHost}.locations."/git/" = {
    basicAuth = {};
    proxyPass = "http://127.0.0.1:27365/";
    proxyWebsockets = true;
  };
}
