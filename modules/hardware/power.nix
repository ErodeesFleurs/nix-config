{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.hardware.power;
in
{
  options.modules.hardware.power = {
    enable = lib.mkEnableOption "Power management configuration";
  };

  config = lib.mkIf cfg.enable {
    powerManagement = {
      enable = true;
      powertop = {
        enable = true;
      };
    };

    services.power-profiles-daemon = {
      enable = true;
    };
  };
}
