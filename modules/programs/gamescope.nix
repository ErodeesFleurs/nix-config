{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.programs.gamescope;
in
{
  options.modules.programs.gamescope = {
    enable = lib.mkEnableOption "Gamescope";
  };

  config = lib.mkIf cfg.enable {
    programs.gamescope = {
      enable = true;
      capSysNice = true;
      args = [ ];
    };
  };
}
