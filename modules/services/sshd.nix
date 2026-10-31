{ config, pkgs, ... }:
{
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.Banner = "${pkgs.writeText "sshd-banner.txt" ''
    Howdy, partner!
  ''}";

  networking.firewall.allowedTCPPorts = [ 22 ];
}
