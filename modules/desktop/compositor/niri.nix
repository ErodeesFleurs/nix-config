{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.compositor.niri;
in
{
  options.modules.compositor.niri = {
    enable = lib.mkEnableOption "Niri compositor";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.niri;
      description = "The Niri package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = cfg.package;
    };
  };

}
