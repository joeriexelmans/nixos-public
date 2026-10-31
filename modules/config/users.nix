{ config, pkgs, ... }:
{
  users.users.maestro = {
    isNormalUser = true;
    description = "Joeri Exelmans";
    extraGroups = [ "networkmanager" "wheel" "vboxusers" "docker" "video" ];
    packages = with pkgs; [];
  };
}

