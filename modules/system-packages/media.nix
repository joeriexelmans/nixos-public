{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vlc
    gimp
    inkscape
    xournalpp
    drawio
    eog
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        obs-backgroundremoval
      ];
    })
    pavucontrol
    pamixer # command line volume control
    audacity
    cheese
    playerctl # command line media control (play/pause)
    supersonic
    easyeffects

    gpu-screen-recorder-gtk # great screen recorder
  ];

  programs.gpu-screen-recorder = {
    enable = true;
  };

  programs.droidcam.enable = true;
}
