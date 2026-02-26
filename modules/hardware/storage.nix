{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.hardware.storage;
in
{
  options.modules.hardware.storage = {
    enable = lib.mkEnableOption "存储与 GVFS 模块";

    # GVFS 服务开关（映射到 services.gvfs.enable）
    gvfs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "是否启用 GNOME 虚拟文件系统（GVFS），用于桌面环境的可移动设备访问";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.gvfs.enable = cfg.gvfs.enable;
  };
}
