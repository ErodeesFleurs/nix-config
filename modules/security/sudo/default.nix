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
    enable = lib.mkEnableOption "sudo 与 polkit 配置";

    use-rust = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        使用 Rust 实现的 `sudo-rs` 替代传统的 `sudo`。
      '';
    };

    enable-polkit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        启用 PolicyKit（polkit）以提供细粒度权限控制。
      '';
    };

    wheel-needs-password = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        是否要求 `wheel` 组用户在使用 sudo 时输入密码。
      '';
    };

    extra-rules = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = ''
        额外的 sudo 或 sudo-rs 规则（以 attrs 列表方式提供）。
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

    # 根据 use-rust 在 sudo-rs 与传统 sudo 之间选择。
    security = lib.mkMerge [
      # 根据选项启用/禁用 polkit。
      { polkit.enable = cfg.enable-polkit; }

      (lib.mkIf cfg.use-rust {
        # 在需要时优先使用 sudo-rs
        sudo.enable = false;
        sudo-rs = {
          enable = true;
          wheelNeedsPassword = cfg.wheel-needs-password;
          extraRules = cfg.extra-rules;
        };
      })

      (lib.mkIf (!cfg.use-rust) {
        # 使用传统的 sudo 包
        sudo = {
          enable = true;
          wheelNeedsPassword = cfg.wheel-needs-password;
          extraRules = cfg.extra-rules;
        };
        # 如果不使用 sudo-rs 则显式禁用它
        sudo-rs.enable = false;
      })
    ];

    # 当用户配置可能产生矛盾时提示
    # NixOS 的 `warnings` 选项期望一个字符串列表；当条件成立时返回一个列表
    warnings = lib.optional (cfg.use-rust && (cfg.enable-polkit == false)) [
      "在禁用 polkit 的同时启用 sudo-rs 可能会影响某些桌面集成（它们可能依赖 polkit）。"
    ];
  };
}
