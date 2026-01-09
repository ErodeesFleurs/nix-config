{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  hyprland-packages = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
  cfg = config.modules.programs.hyprland;
in
{
  options.modules.programs.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager";

    xwayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable XWayland support";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = cfg.xwayland;
      withUWSM = false;
      package = hyprland-packages.hyprland;
      portalPackage = hyprland-packages.xdg-desktop-portal-hyprland;
    };
  };
}
