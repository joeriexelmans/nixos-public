{ config, homepageHost, ... }: 
{
  services.nginx = {
    virtualHosts.${homepageHost} = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        charset UTF-8;
        more_set_headers 'Server: NixOS';
      '';
      locations."/" = {
        root = "/schijf/public/homepage/";
      };
    };
  };
}
