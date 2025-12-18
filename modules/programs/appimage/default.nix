{
  config,
  lib,
  ...
}:

/*
  nix-config/modules/programs/appimage/default.nix
  AppImage program module — AppImage 支持模块

  CN:
  本模块为 AppImage 提供声明式开关，允许在配置中启用/禁用 AppImage 支持以及 binfmt 相关功能。
  建议通过 `modules.programs.appimage` 选项进行控制（该命名空间属于 programs 模块集合）。

  EN:
  Declarative module for AppImage support. Exposes options under `modules.programs.appimage`
  to enable AppImage integration and optional binfmt support.
*/

let
  cfg = config.modules.programs.appimage;
in
{
  options.modules.programs.appimage = {
    enable = lib.mkEnableOption "AppImage support / AppImage 支持";

    binfmt = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Register AppImage with binfmt (enable automatic execution via kernel binfmt_misc).
        CN: 是否为 AppImage 注册 binfmt（通过内核 binfmt_misc 实现可执行文件自动识别与执行）。
        EN: Whether to register AppImage with binfmt to allow direct execution via kernel binfmt_misc.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.appimage = {
      enable = true;
      binfmt = cfg.binfmt;
    };
  };
}
