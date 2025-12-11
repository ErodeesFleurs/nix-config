{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.direnv;
in
{
  options.homeModules.direnv = {
    enable = lib.mkEnableOption "direnv (automatic environment switching)";

    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Nushell integration for direnv";
    };

    enableNixDirenv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable nix-direnv for fast directory environment loading";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableNushellIntegration = cfg.enableNushellIntegration;
      nix-direnv.enable = cfg.enableNixDirenv;
    };
  };
}
