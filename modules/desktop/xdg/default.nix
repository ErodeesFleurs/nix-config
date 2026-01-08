{
  config,
  lib,
  pkgs,
  inputs,
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
        hyprland.default = [
          "hyprland"
          "gtk"
        ];
      };

      configPackages = with pkgs; [
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];

      extraPortals = [ ];

      xdgOpenUsePortal = true;
    };
  };
}
