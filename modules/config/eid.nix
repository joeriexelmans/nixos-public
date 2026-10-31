{ config, pkgs, ... }:
{  
  services.pcscd.enable = true; # Belgian eID

  # Belgian eID software and hardware drivers
  environment.systemPackages = with pkgs; [
    eid-mw
    pcsc-tools
    pcsclite
    ccid
    acsccid
    libacr38u
    scmccid
    qdigidoc
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    firefox = pkgs.firefox.override { pkcs11Modules = [ pkgs.eid-mw ]; };
  };
}
