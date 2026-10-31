{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fstl # STL viewer
    openscad
    solvespace
  ];
}
