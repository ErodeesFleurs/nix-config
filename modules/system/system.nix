{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.system;
in
{
  options.modules.system = {
    enable = lib.mkEnableOption "System base configuration";

    trustedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "fleurs" ];
      description = "List of trusted Nix users";
    };

    autoOptimise = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically optimize the Nix store";
    };

    autoGC = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically run garbage collection";
    };

    gcOptions = lib.mkOption {
      type = lib.types.str;
      default = "--delete-older-than 7d";
      description = "Options for garbage collection";
    };

    allowUnfree = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow unfree packages";
    };

    permittedInsecurePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of permitted insecure packages";
      example = [ "openssl-1.0.2u" ];
    };

    substituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "https://cache.nixos.org" ];
      description = "List of binary cache substituters";
    };

    trustedPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of trusted public keys for substituters";
    };

    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "26.05";
      description = "NixOS state version";
    };

    enableInit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable nixos-init";
    };

    overlayMutable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Make /etc overlay mutable";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nix 系统设置
    nix = {
      settings = {
        experimental-features = [
          "flakes"
          "nix-command"
        ];
        trusted-users = cfg.trustedUsers;
        substituters = cfg.substituters;
        trusted-public-keys = cfg.trustedPublicKeys;
      };

      optimise = {
        automatic = cfg.autoOptimise;
      };

      gc = lib.mkIf cfg.autoGC {
        automatic = true;
        dates = "weekly";
        options = cfg.gcOptions;
      };
    };

    # 系统配置
    system = {
      stateVersion = cfg.stateVersion;
      nixos-init.enable = cfg.enableInit;
      etc.overlay = {
        enable = true;
        mutable = cfg.overlayMutable;
      };
    };
  };
}
