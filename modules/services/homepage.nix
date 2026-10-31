{ config, homepageHost, ... }: 
{
  services.nginx = {
    virtualHosts.${homepageHost} = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        root = "/schijf/public/homepage/";
      };
    };
  };
}
