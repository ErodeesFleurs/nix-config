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
  };

  config = lib.mkIf cfg.enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
