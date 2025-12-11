{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.system.nh;
in
{
  options.modules.system.nh = {
    enable = lib.mkEnableOption "nh (Nix helper tool)";

    clean = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable automatic cleanup with nh.
          Note: This conflicts with nix.gc.automatic.
          Only enable one of them.
        '';
      };

      extraArgs = lib.mkOption {
        type = lib.types.str;
        default = "--keep-since 3d --keep 2";
        description = "Extra arguments for nh clean";
      };
    };

    flake = lib.mkOption {
      type = lib.types.str;
      default = "/home/fleurs/nix-config";
      description = "Path to the flake configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      clean = lib.mkIf cfg.clean.enable {
        enable = true;
        extraArgs = cfg.clean.extraArgs;
      };
      flake = cfg.flake;
    };

    # Warn if both nh.clean and nix.gc.automatic are enabled
    warnings =
      lib.optional (cfg.clean.enable && config.nix.gc.automatic or false)
        "Both nh.clean and nix.gc.automatic are enabled. This may cause conflicts. Please disable one of them.";
  };
}
