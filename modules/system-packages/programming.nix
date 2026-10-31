{ config, pkgs, ... }:
{
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" # needed for Sublime Text 4
  ];

  environment.systemPackages = with pkgs; [
    git

    vscode

    sublime4
    sublime-merge

    graphviz
  ];
}