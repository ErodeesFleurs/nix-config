{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.hardware.printing;
in
{
  options.modules.hardware.printing = {
    enable = lib.mkEnableOption "打印模块（Printing module）";

    # 是否实际启用 printing 服务（services.printing.enable）
    service = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "是否启用系统的打印服务（services.printing.enable）";
      };
    };

    # 要安装/启用的打印驱动包列表（使用 pkgs 命名空间中的包）
    drivers = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        hplip
        gutenprint
        splix
      ];
      description = "打印驱动包列表（drivers，将映射到 services.printing.drivers）";
    };
  };

  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = cfg.service.enable;
      drivers = cfg.drivers;
    };
  };
}
