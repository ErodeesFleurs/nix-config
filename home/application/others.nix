{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.others;
in
{
  options.homeModules.others = {
    aseprite = {
      enable = lib.mkEnableOption "Aseprite (pixel art tool)";
    };
  };

  config = {
    home.packages = with pkgs; [
      (lib.mkIf cfg.aseprite.enable aseprite)
    ];
  };
}
