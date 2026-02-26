{ config, lib, ... }:
let
  cfg = config.homeModules.hyprpaper;
in
{
  options.homeModules.hyprpaper = {
    enable = lib.mkEnableOption "Hyprpaper wallpaper manager user configuration";
  };
  config = lib.mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = true;
        splash_offset = 20;
        splash_opacity = 0.8;
      };
    };
  };
}
