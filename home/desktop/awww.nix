{ config, lib, ... }:
let
  cfg = config.home-modules.desktop.awww;
in
{
  options.home-modules.desktop.awww = {
    enable = lib.mkEnableOption "awww Wayland compositor configuration";
  };

  config = lib.mkIf cfg.enable {
    services.awww = {
      enable = true;
      extraArgs = [ ];
    };
  };
}
