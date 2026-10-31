{ config, ... }:
{
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.banner = ''
    Howdy, partner!
  '';

  networking.firewall.allowedTCPPorts = [ 22 ];
}
