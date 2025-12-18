/*
  nix-config/modules/system/sudo.nix
  Sudo & Policy configuration module — Sudo / polkit 配置模块

  CN: 本模块提供对 sudo 或 sudo-rs（Rust 实现）以及 PolicyKit 的集中声明式配置。
      文档采用中英文双语说明，便于中英文维护者理解配置项含义与注意事项。
  EN: This module centralizes configuration for `sudo` or `sudo-rs` (Rust implementation)
      and PolicyKit (polkit). Documentation is bilingual (CN/EN) for maintainability.

  Notes:
  - The module exposes a single toggle `enable` to turn the whole feature set on/off,
    plus options to choose the sudo implementation and configure common behaviors.
  - Keep `useRust` consistent with available packages in your system – set to false to use classic sudo.
*/

{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.security.sudo;
in
{
  options.modules.security.sudo = {
    enable = lib.mkEnableOption "Sudo configuration / sudo 与 polkit 配置";

    useRust = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Use the Rust implementation `sudo-rs` instead of the traditional `sudo`.

        CN: 使用 Rust 实现的 `sudo-rs` 替代传统的 `sudo`。
        EN: Choose the Rust-based `sudo-rs` implementation when true; otherwise the classic `sudo` will be used.
      '';
    };

    enablePolkit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable PolicyKit (polkit) for fine-grained privilege authorization.

        CN: 启用 PolicyKit（polkit）以提供细粒度权限控制。
        EN: Enable polkit service used by many desktop and system components for authorization.
      '';
    };

    wheelNeedsPassword = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether users in the `wheel` group must provide a password when using sudo.

        CN: 是否要求 `wheel` 组用户在使用 sudo 时输入密码。
        EN: When true, members of `wheel` will be prompted for a password; set to false to allow passwordless sudo for that group.
      '';
    };

    extraRules = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = ''
        Additional sudo/sudo-rs rules to apply.

        CN: 额外的 sudo 或 sudo-rs 规则（以 attrs 列表方式提供）。
        EN: Extra rule sets (attribute list). Example provided in `example`.
      '';
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

    # Choose between sudo-rs and classic sudo.
    # CN: 根据 useRust 在 sudo-rs 与传统 sudo 之间选择。
    security = lib.mkMerge [
      # Ensure PolicyKit is configured according to the option.
      # CN: 根据选项启用/禁用 polkit。
      { polkit.enable = cfg.enablePolkit; }

      (lib.mkIf cfg.useRust {
        # Prefer sudo-rs when requested
        sudo.enable = false;
        sudo-rs = {
          enable = true;
          wheelNeedsPassword = cfg.wheelNeedsPassword;
          extraRules = cfg.extraRules;
        };
      })

      (lib.mkIf (!cfg.useRust) {
        # Use the traditional sudo package
        sudo = {
          enable = true;
          wheelNeedsPassword = cfg.wheelNeedsPassword;
          extraRules = cfg.extraRules;
        };
        # Explicitly disable sudo-rs if not using it
        sudo-rs.enable = false;
      })
    ];

    # Helpful warning if user config may be contradictory
    warnings = lib.optionalString (cfg.useRust && cfg.enablePolkit == false) ''
      EN: Using `sudo-rs` without polkit may limit some desktop integrations that expect polkit.
      CN: 在禁用 polkit 的同时启用 sudo-rs 可能会影响某些桌面集成（它们可能依赖 polkit）。
    '';
  };
}
