{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.localization.time;
in
{
  options.modules.localization.time = {
    enable = lib.mkEnableOption "时间/时区模块";

    time-zone = lib.mkOption {
      type = lib.types.str;
      default = "Asia/Shanghai";
      description = "系统时区（例如 \"Asia/Shanghai\"）";
    };
  };

  config = lib.mkIf cfg.enable {
    time = {
      timeZone = cfg.time-zone;
    };
  };
}
