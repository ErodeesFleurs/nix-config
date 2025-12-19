{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.programs.appimage;
in
{
  options.modules.programs.appimage = {
    enable = lib.mkEnableOption "AppImage 支持";

    binfmt = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        是否为 AppImage 注册 binfmt（通过内核 binfmt_misc 实现可执行文件自动识别与执行）。
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
