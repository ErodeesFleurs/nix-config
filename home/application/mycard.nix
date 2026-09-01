{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.homeModules.mycard;
in
{
  options.homeModules.mycard = {
    enable = lib.mkEnableOption "MyCard Yu-Gi-Oh! launcher";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      inputs.fleurs-nur.packages.${pkgs.stdenv.hostPlatform.system}.mycard
    ];
  };
}
