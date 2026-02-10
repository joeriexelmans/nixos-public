{ pkgs }: with pkgs;
let
  firefoxWithBelgianEid = firefox.override { pkcs11Modules = [ eid-mw ]; };

  sublime4Cracked = sublime4.overrideAttrs (finalAttrs: previousAttrs: {
    sublime_text = previousAttrs.sublime_text.overrideAttrs (finalAttrs: previousAttrs:
      let
          pattern     = "807905000f94c2"; # hex pattern to look for
          replacement = "c6410501b20090"; # replacement
      in {
        postFixup = ''
          # Based on: https://gist.github.com/opastorello/4d494d627ec9012367028c89cb7a1945

          # Assert that binary contains pattern:
          ${xxd}/bin/xxd -p -c 0 $out/sublime_text | sed '/${pattern}/!{q100}' > /dev/null # exit code '100' if pattern not found

          # Patch binary in-place:
          ${xxd}/bin/xxd -p -c 0 $out/sublime_text | sed 's/${pattern}/${replacement}/' | ${xxd}/bin/xxd -p -c 0 -r > $out/tmp
          mv $out/tmp $out/sublime_text
          chmod +x $out/sublime_text
        '' + previousAttrs.postFixup;
      });
  });
in [
  # Utility
  lf
  tree
  unzip
  killall
  nix-index
  nix-tree # really useful package for searching, figuring out why something's a dependency, etc.
  steam-run
  zip
  unrar
  apg # secure password generator
  fuse3  # User space filesystems - need this to run AppImages with steam-run
  gnupg
  bottles # Wrapper around wine
  kdePackages.filelight # Disk space analysis
  dconf-editor
  gnome-calculator
  gnome-disk-utility
  file-roller
  xfce.xfce4-weather-plugin
  alacritty
  xorg.xkill
  gpu-screen-recorder-gtk # great screen recorder

  # Programming
  git
  kdePackages.kate
  vim
  vimPlugins.vim-nix
  graphviz
  #sublime4Cracked
  sublime4
  sublime-merge
  vscode

  # Network thingy
  chromium
  firefoxWithBelgianEid
  thunderbird
  signal-desktop
  wasistlos
  tor-browser
  zoom-us
  joplin-desktop
  transmission-remote-gtk
  transmission_4-gtk
  dig # DNS debugging
  sshfs
  teams-for-linux # Unofficial teams client

  # Graphics thingy
  gimp
  inkscape
  xournalpp
  drawio
  eog

  # Documents thingy
  libreoffice
  #evince # replaced by GNOME's new document reader
  koreader # epub reader
  hunspell
  hunspellDicts.en-us
  hunspellDicts.en-us-large
  pdfarranger # useful tool to rearrange / split / merge PDF documents
  (texlive.combine {
    inherit (texlive) scheme-small
    awesomebox fontawesome5;
  })

  # Media thingy
  vlc
  (wrapOBS {
    plugins = with obs-studio-plugins; [
      obs-backgroundremoval
    ];
  })
  helvum
  pavucontrol
  pamixer # command line volume control
  audacity
  cheese
  playerctl # command line media control (play/pause)
  #finamp # i no longer use jellyfin
  supersonic
  easyeffects

  # Belgian eID software and hardware drivers
  eid-mw
  pcsc-tools
  pcsclite
  ccid
  acsccid
  libacr38u
  scmccid
  qdigidoc

  solaar # extra options for logitech mouse

  # GNOME stuff
  gnomeExtensions.appindicator
]
