{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.obs;
in
{
  options.homeModules.obs = {
    enable = lib.mkEnableOption "OBS Studio";
  };

  config = lib.mkIf cfg.enable {
    programs.obs-studio.enable = true;
  };
}
