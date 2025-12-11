{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.system.sudo;
in
{
  options.modules.system.sudo = {
    enable = lib.mkEnableOption "Sudo configuration";

    useRust = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use sudo-rs (Rust implementation) instead of traditional sudo";
    };

    enablePolkit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable PolicyKit for privilege escalation";
    };

    wheelNeedsPassword = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether users in the wheel group need a password for sudo";
    };

    extraRules = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Extra sudo rules";
      example = lib.literalExpression ''
        [
          {
            users = [ "alice" ];
            commands = [
              {
                command = "/run/current-system/sw/bin/systemctl";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable PolicyKit

    # Configure sudo or sudo-rs
    security = lib.mkMerge [
      { polkit.enable = cfg.enablePolkit; }

      (lib.mkIf cfg.useRust {
        sudo.enable = false;
        sudo-rs = {
          enable = true;
          wheelNeedsPassword = cfg.wheelNeedsPassword;
          extraRules = cfg.extraRules;
        };
      })

      (lib.mkIf (!cfg.useRust) {
        sudo = {
          enable = true;
          wheelNeedsPassword = cfg.wheelNeedsPassword;
          extraRules = cfg.extraRules;
        };
        sudo-rs.enable = false;
      })
    ];
  };
}
