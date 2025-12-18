{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.xdg;
in
{
  options.modules.xdg = {
    enable = lib.mkEnableOption "XDG portal configuration";

    xdgOpenUsePortal = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use XDG portal for opening files";
    };

    extraPortals = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ pkgs.xdg-desktop-portal-gtk ];
      description = "Additional XDG desktop portals";
    };

    config = lib.mkOption {
      type = lib.types.attrs;
      default = {
        common.default = [ "gtk" ];
        hyprland.default = [
          "gtk"
          "hyprland"
        ];
      };
      description = "XDG portal configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = cfg.xdgOpenUsePortal;
      config = cfg.config;
      extraPortals = cfg.extraPortals;
    };
  };
}
