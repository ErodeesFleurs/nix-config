{ config, lib, ... }:
let
  cfg = config.homeModules.desktop.swww;
in
{
  options.homeModules.desktop.swww = {
    enable = lib.mkEnableOption "Swww Wayland compositor configuration for Home Manager";

    extra-args = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional command-line arguments to pass to Swww on startup";
    };
  };

  config = lib.mkIf cfg.enable {
    services.swww = {
      enable = true;
      extraArgs = cfg.extra-args;
    };
  };
}
