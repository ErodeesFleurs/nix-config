{ config, lib, ... }:
let
  cfg = config.home-modules.application.playerctl;
in
{
  options.home-modules.application.playerctl = {
    enable = lib.mkEnableOption "Playerctl (media player controller)";
  };

  config = lib.mkIf cfg.enable {
    services.playerctl = {
      enable = true;
    };
  };

}
