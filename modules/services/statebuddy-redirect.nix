{ config, fileserverHost, basicAuth, ... }:
{
  services.nginx = {
    virtualHosts.${fileserverHost} = {
      root = "/schijf";

      locations."/public/statebuddy/v2" = {
        return = "301 https://statebuddy.s3-website.fr-par.scw.cloud/tags/latest.html";
      };
      locations."/public/statebuddy/v2/" = {
        return = "301 https://statebuddy.s3-website.fr-par.scw.cloud/tags/latest.html";
      };
      locations."/public/statebuddy/v2/index.html" = {
        return = "301 https://statebuddy.s3-website.fr-par.scw.cloud/tags/latest.html";
      };

    };
  };
}
