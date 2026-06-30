{
  config,
  lib,
  pkgs,
  waybarBodyCssPath,
}:

let
  waybar = import ./waybar.nix { inherit waybarBodyCssPath; };
  dunst = import ./dunst.nix { inherit config lib pkgs; };
  btop = import ./btop.nix { inherit config lib; };
  ghostty = import ./ghostty.nix { inherit config lib; };
  firefox = import ./firefox.nix { inherit config lib pkgs; };
  hyprlock = import ./hyprlock.nix { inherit config lib; };
  yazi = import ./yazi.nix { inherit config lib; };
  gitui = import ./gitui.nix { inherit config lib; };
  helix = import ./helix.nix { inherit config lib; };
  zed = import ./zed.nix { inherit config lib; };
  fastfetch = import ./fastfetch.nix { inherit config lib; };

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
  ];
  enabledApps = builtins.filter (app: app.enable) apps;
in
{
  outputDirs = lib.concatStringsSep " " (lib.concatMap (app: app.outputDirs) enabledApps);

  generate =
    { polarity }:
    lib.concatStringsSep "\n" (map (app: app.generate { inherit polarity; }) enabledApps);

  activation = lib.foldl' (acc: app: acc // (app.activation or { })) { } enabledApps;
  xdgConfig = lib.foldl' (acc: app: acc // (app.xdgConfig or { })) { } enabledApps;
}
