{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeModules.nautilus;
in
{
  options.homeModules.nautilus = {
    enable = lib.mkEnableOption "Nautilus file manager";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nautilus;
      description = "Nautilus file manager package";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
