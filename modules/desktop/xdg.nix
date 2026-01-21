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
  };

  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;

      config = {
        common.default = [ "gtk" ];
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.portal.FileChooser" = "gtk";
          "org.freedesktop.portal.OpenURI" = "gtk";
        };
      };

      configPackages = [ ];

      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];

      xdgOpenUsePortal = true;
    };
  };
}
