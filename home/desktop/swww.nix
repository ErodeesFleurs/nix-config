{ config, lib, ... }:
let
  cfg = config.home-modules.desktop.swww;
in
{
  options.home-modules.desktop.swww = {
    enable = lib.mkEnableOption "Swww Wayland compositor configuration";
  };

  config = lib.mkIf cfg.enable {
    services.swww = {
      enable = true;
      extraArgs = [ ];
    };
  };
}
