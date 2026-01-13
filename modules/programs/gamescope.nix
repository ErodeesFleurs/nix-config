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
    enable = lib.mkEnableOption "Gamescope 封装模块";

    cap-sys-nice = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        允许 Gamescope 使用 CAP_SYS_NICE 以获得实时调度权限（提高性能）。
      '';
    };

    args = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "--rt"
        "--expose-wayland"
      ];
      description = ''
        传递给 gamescope 的额外命令行参数。
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gamescope = {
      enable = true;
      capSysNice = cfg.cap-sys-nice;
      args = cfg.args;
    };

    # Ensure gamescope package is available when enabled
    environment.systemPackages = lib.mkIf cfg.enable [
      pkgs.gamescope
    ];
  };
}
