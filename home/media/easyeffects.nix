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
  };

  config = lib.mkIf cfg.enable {
    services.easyeffects = {
      enable = true;
    };
  };
}
