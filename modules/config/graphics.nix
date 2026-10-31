{ config, pkgs, ... }:
{
  hardware.graphics.enable = true; # enable OpenGL
  hardware.graphics.enable32Bit = true; # also install 32 bit drivers (in order to run 32 bit apps under Wine)
  hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver # hardware accelerated video decoding on Intel
      intel-vaapi-driver
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.deviceSection = ''
    Option "TearFree" "true"
  '';
}
