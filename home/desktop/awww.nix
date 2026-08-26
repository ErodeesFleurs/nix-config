{ config, lib, ... }:
let
  cfg = config.homeModules.desktop.awww;
in
{
  options.homeModules.desktop.awww = {
    enable = lib.mkEnableOption "awww Wayland compositor configuration";
  };

  config = lib.mkIf cfg.enable {
    services.awww = {
      enable = true;
      extraArgs = [ ];
    };
  };
}
