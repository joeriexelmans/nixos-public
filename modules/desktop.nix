{ config, pkgs, ... }:
{
  imports = [
      ./config/eid.nix
      ./config/graphics.nix
      ./config/keyboard.nix
      ./config/locale.nix
      ./config/pipewire.nix
      ./config/users.nix

      ./system-packages/base.nix
      ./system-packages/cad.nix
      ./system-packages/communication.nix
      ./system-packages/media.nix
      ./system-packages/office.nix
      ./system-packages/programming.nix
  ];
}