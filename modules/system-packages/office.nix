{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    libreoffice
    koreader # epub reader
    hunspell
    hunspellDicts.en-us
    hunspellDicts.en-us-large
    pdfarranger # useful tool to rearrange / split / merge PDF documents
    (texlive.combine {
      inherit (texlive) scheme-small
      awesomebox fontawesome5;
    })
  ];
}
