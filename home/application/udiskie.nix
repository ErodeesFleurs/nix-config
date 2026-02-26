{ config, lib, ... }:
let
  cfg = config.home-modules.application.udiskie;
in
{
  options.home-modules.application.udiskie = {
    enable = lib.mkEnableOption "Udiskie automounting configuration for Home Manager";
  };

  config = lib.mkIf cfg.enable {
    services.udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "auto";
    };
  };
}
