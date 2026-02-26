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
    enable = lib.mkEnableOption "AppImage";
  };

  config = lib.mkIf cfg.enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
