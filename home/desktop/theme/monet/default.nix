{
  config,
  lib,
  pkgs,
  waybarBodyCssPath,
}:

let
  themeLib = import ./lib.nix { inherit config lib; };
  waybar = import ./waybar.nix { inherit pkgs themeLib waybarBodyCssPath; };
  dunst = import ./dunst.nix {
    inherit
      config
      lib
      pkgs
      themeLib
      ;
  };
  btop = import ./btop.nix { inherit config themeLib; };
  ghostty = import ./ghostty.nix { inherit config themeLib; };
  firefox = import ./firefox.nix {
    inherit
      config
      lib
      pkgs
      themeLib
      ;
  };
  hyprlock = import ./hyprlock.nix { inherit config themeLib; };
  yazi = import ./yazi.nix { inherit config themeLib; };
  gitui = import ./gitui.nix { inherit config themeLib; };
  helix = import ./helix.nix { inherit config themeLib; };
  zed = import ./zed.nix { inherit config themeLib; };
  fastfetch = import ./fastfetch.nix { inherit config themeLib; };
  starship = import ./starship.nix { inherit config themeLib; };
  mpv = import ./mpv.nix { inherit config themeLib; };
  niri = import ./niri.nix { inherit config themeLib; };
  gtk = import ./gtk.nix { inherit themeLib; };
  qt = import ./qt.nix { inherit config themeLib; };
  delta = import ./delta.nix { inherit config themeLib; };
  vicinae = import ./vicinae.nix {
    inherit
      config
      lib
      themeLib
      ;
  };
  fcitx5 = import ./fcitx5.nix {
    inherit
      config
      lib
      pkgs
      themeLib
      ;
  };

  apps = [
    waybar
    dunst
    btop
    ghostty
    firefox
    hyprlock
    yazi
    gitui
    helix
    zed
    fastfetch
    starship
    mpv
    niri
    gtk
    qt
    delta
    vicinae
    fcitx5
  ];
in
themeLib.collect apps
