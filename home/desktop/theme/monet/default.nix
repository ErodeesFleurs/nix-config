{
  config,
  lib,
  pkgs,
  waybarBodyCssPath,
}:

let
  themeLib = import ./lib.nix { inherit config lib pkgs; };
  waybar = import ./waybar.nix { inherit themeLib waybarBodyCssPath; };
  mako = import ./mako.nix {
    inherit
      config
      lib
      pkgs
      themeLib
      ;
  };
  btop = import ./btop.nix { inherit config themeLib; };
  ghostty = import ./ghostty.nix { inherit config lib themeLib; };
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
  helix = import ./helix.nix { inherit config themeLib; };
  zed = import ./zed.nix { inherit config themeLib; };
  fastfetch = import ./fastfetch.nix { inherit config themeLib; };
  starship = import ./starship.nix { inherit config themeLib; };
  nushell = import ./nushell.nix { inherit config themeLib; };
  mpv = import ./mpv.nix { inherit config themeLib; };
  niri = import ./niri.nix { inherit config themeLib; };
  gtk = import ./gtk.nix { inherit config lib themeLib; };
  icons = import ./icons.nix { inherit lib themeLib; };
  delta = import ./delta.nix { inherit config themeLib; };
  discord = import ./discord.nix { inherit config themeLib; };
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
    mako
    btop
    ghostty
    firefox
    hyprlock
    yazi
    helix
    zed
    fastfetch
    starship
    nushell
    mpv
    niri
    gtk
    icons
    delta
    discord
    vicinae
    fcitx5
  ];
in
themeLib.collect apps
