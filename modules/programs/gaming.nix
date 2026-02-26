{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.programs.gaming;
in
{
  options.modules.programs.gaming = {
    enable = lib.mkEnableOption "Gaming support and optimizations";
  };

  config = lib.mkIf cfg.enable {
    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;
        };

        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };

        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    hardware.graphics = {
      enable32Bit = true;
    };

  };
}
