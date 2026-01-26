{ config, lib, ... }:

let
  cfg = config.modules.nix or { };
in
{
  options.modules.nix = {
    enable = lib.mkEnableOption "Nix subsystem configuration / Nix 设置";

    trusted-users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "fleurs" ];
      description = ''
        信任的 Nix 用户列表（用于 `trusted-users` 设置）。
      '';
    };

    auto-optimise = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        是否自动优化 Nix 存储（例如减少碎片、整理路径）。
      '';
    };

    auto-gc = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        是否自动执行垃圾回收（nix store GC）。与其它自动 GC 工具（例如 nh.clean）可能冲突。
      '';
    };

    gc-options = lib.mkOption {
      type = lib.types.str;
      default = "--delete-older-than 7d";
      description = ''
        自动 GC 时传递给 gc 的参数（例如保留时间）。
      '';
    };

    substituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "https://cache.nixos.org" ];
      description = ''
        二进制缓存替代源列表（substituters），用于加速构建与部署。
      '';
    };

    trusted-public-keys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        用于验证替代缓存的公钥列表（trusted-public-keys）。
      '';
    };
  };

  config = lib.mkIf (cfg.enable) {
    # 从所选配置应用的 Nix 设置
    nix = {
      settings = lib.mkIf cfg.enable {
        # 启用此配置集常用的实验性功能。
        experimental-features = [
          "flakes"
          "nix-command"
        ];

        # 受信任的用户与二进制缓存
        trusted-users = cfg.trusted-users;
        substituters = cfg.substituters;
        trusted-public-keys = cfg.trusted-public-keys;
      };

      # 为与其它模块兼容，保留原始的 `optimise` 选项名
      optimise = {
        automatic = cfg.auto-optimise;
      };

      # 自动 GC 配置（仅在 autoGC 为 true 时启用）
      gc = lib.mkIf cfg.auto-gc {
        automatic = true;
        dates = "weekly";
        options = cfg.gc-options;
      };
    };
  };
}
