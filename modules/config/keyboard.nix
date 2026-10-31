{ config, ... }:
{
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use X keyboard config (xserver.xkb.options) in tty.
  };

  services.xserver = {
    autoRepeatDelay = 150;
    xkb.layout = "us"; # keymap
    xkb.options = "eurosign:e,caps:escape";
  };
}
