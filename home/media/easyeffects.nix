{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.easyeffects;
in
{
  options.homeModules.easyeffects = {
    enable = lib.mkEnableOption "EasyEffects audio effects";

    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically start EasyEffects on login";
    };
  };

  config = lib.mkIf cfg.enable {
    services.easyeffects = {
      enable = true;
    };
  };
}
