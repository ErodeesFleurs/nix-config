{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.homeModules.starbound;
in
{
  options.homeModules.starbound = {
    enable = lib.mkEnableOption "OpenStarbound game client";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      inputs.fleurs-nur.packages.${pkgs.stdenv.hostPlatform.system}.openstarbound
    ];
  };
}
