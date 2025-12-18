{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.programs.gamescope;
in
{
  options.modules.programs.gamescope = {
    enable = lib.mkEnableOption "Gamescope wrapper / Gamescope 封装模块";

    capSysNice = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Allow Gamescope to use CAP_SYS_NICE for realtime scheduling.
        CN: 允许 Gamescope 使用 CAP_SYS_NICE 以获得实时调度权限（提高性能）。
        EN: Allow Gamescope to use CAP_SYS_NICE for realtime scheduling (improves performance).
      '';
    };

    args = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "--rt"
        "--expose-wayland"
      ];
      description = ''
        Additional command-line arguments passed to gamescope.
        CN: 传递给 gamescope 的额外命令行参数。
        EN: Extra command-line arguments for gamescope.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gamescope = {
      enable = true;
      capSysNice = cfg.capSysNice;
      args = cfg.args;
    };

    # Ensure gamescope package is available when enabled
    environment.systemPackages = lib.mkIf cfg.enable [
      pkgs.gamescope
    ];
  };
}
