{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.system.users;
in
{
  options.modules.system.users = {
    # This module is deprecated and should not be used.
    # User accounts should be defined in host-specific configuration files
    # (e.g., hosts/spectre/users.nix) instead.
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable the legacy user configuration module.
        This is deprecated - users should be defined in host-specific configs.
      '';
    };

    defaultUser = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "fleurs";
        description = "Default username";
      };

      description = lib.mkOption {
        type = lib.types.str;
        default = "ErodeesFleurs";
        description = "User description";
      };

      shell = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nushell;
        description = "Default shell for the user";
      };

      hashedPassword = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "User's hashed password";
      };

      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "networkmanager"
          "wheel"
          "libvirt"
          "kvm"
        ];
        description = "Additional groups for the user";
      };
    };

    enableUserborn = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable userborn service for declarative user management";
    };

    mutableUsers = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow mutable user accounts";
    };
  };

  config = lib.mkMerge [
    # Userborn service (can be enabled independently)
    (lib.mkIf cfg.enableUserborn {
      services.userborn = {
        enable = true;
      };
    })

    # User configuration (deprecated, disabled by default)
    (lib.mkIf cfg.enable {
      users = {
        mutableUsers = cfg.mutableUsers;
        users.${cfg.defaultUser.name} = {
          isNormalUser = true;
          description = cfg.defaultUser.description;
          extraGroups = cfg.defaultUser.extraGroups;
          shell = cfg.defaultUser.shell;
          hashedPassword = lib.mkIf (cfg.defaultUser.hashedPassword != null) cfg.defaultUser.hashedPassword;
        };
      };
    })
  ];
}
