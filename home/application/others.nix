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
    aseprite = lib.mkEnableOption "Aseprite (pixel art tool)";
  };

  config = {
    home.packages = with pkgs; [
      (lib.mkIf cfg.aseprite aseprite)
    ];
  };
}
