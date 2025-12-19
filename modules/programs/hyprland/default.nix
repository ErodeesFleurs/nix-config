{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
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

    with-uwsm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable UWSM integration";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = cfg.xwayland;
      withUWSM = cfg.with-uwsm;
      package = inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
  };
}
