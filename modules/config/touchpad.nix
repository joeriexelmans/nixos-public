{ config, ... }:
{
  services.libinput.enable = true; # enable touchpad
  services.libinput.mouse.middleEmulation = false; # middle mouse button emulation (left+right = middle)
}
