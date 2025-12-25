{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.obs;
in
{
  options.homeModules.obs = {
    enable = lib.mkEnableOption "OBS Studio";

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        obs-studio-plugins.wlrobs
      ];
      description = "List of OBS Studio plugins to install";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = cfg.plugins;
    };
  };
}
