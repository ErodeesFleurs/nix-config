{ config, lib, ... }:
let
  cfg = config.homeModules.application.playerctl;
in
{
  options.homeModules.application.playerctl = {
    enable = lib.mkEnableOption "Playerctl (media player controller)";
  };

  config = lib.mkIf cfg.enable {
    services.playerctld = {
      enable = true;
    };
  };

}
