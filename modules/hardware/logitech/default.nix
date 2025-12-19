{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.hardware.logitech;
in
{
  options.modules.hardware.logitech = {
    enable = lib.mkEnableOption "Logitech 硬件支持模块";

    wireless = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "启用 Logitech 无线设备支持（hardware.logitech.wireless.enable）";
      };

      enable-graphical = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "启用图形化的 Logitech 无线管理工具（hardware.logitech.wireless.enableGraphical）";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.logitech = {
      wireless = {
        enable = cfg.wireless.enable;
        enableGraphical = cfg.wireless.enable-graphical;
      };
    };
  };
}
