{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.compositor.hyprland;
in
{
  options.modules.compositor.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = false;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
  };
}
