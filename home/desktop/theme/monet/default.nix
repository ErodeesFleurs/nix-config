{
  config,
  lib,
  pkgs,
  waybarBodyCssPath,
}:

let
  themeLib = import ./lib.nix { inherit config lib; };
  waybar = import ./waybar.nix { inherit pkgs themeLib waybarBodyCssPath; };
  dunst = import ./dunst.nix { inherit config lib pkgs themeLib; };
  btop = import ./btop.nix { inherit config themeLib; };
  ghostty = import ./ghostty.nix { inherit config themeLib; };
  firefox = import ./firefox.nix { inherit config lib pkgs; };
  hyprlock = import ./hyprlock.nix { inherit config themeLib; };
  yazi = import ./yazi.nix { inherit config themeLib; };
  gitui = import ./gitui.nix { inherit config themeLib; };
  helix = import ./helix.nix { inherit config themeLib; };
  zed = import ./zed.nix { inherit config themeLib; };
  fastfetch = import ./fastfetch.nix { inherit config themeLib; };
  starship = import ./starship.nix { inherit config themeLib; };
  mpv = import ./mpv.nix { inherit config themeLib; };

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
  ];
in
themeLib.collect apps
