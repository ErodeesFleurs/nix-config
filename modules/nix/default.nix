{ config, lib, ... }:

/*
  nix-config/modules/nix/default.nix
  Nix settings & GC implementation (submodule)

  CN:
  本子模块负责根据上层 `modules.nix` 的选项应用 Nix 相关设置（例如 experimental features、
  trusted-users、substituters、nixpkgs 配置与自动 GC/optimise）。模块仅使用 `modules.nix` 命名空间。
  EN:
  Apply Nix-related settings according to the `modules.nix` options: experimental features,
  trusted-users, substituters, nixpkgs config (allowUnfree / permittedInsecurePackages), and automatic GC/optimise.
  This module uses the `modules.nix` namespace only.
*/

let
  # Prefer explicit `modules.nix` if provided; use the new namespace only.
  cfg = config.modules.nix or { };
in
{
  ####################################################################
  # Options: declare the `modules.nix` option set (mirrors legacy keys)
  ####################################################################
  options.modules.nix = {
    enable = lib.mkEnableOption "Nix subsystem configuration / Nix 设置";

    trustedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "fleurs" ];
      description = ''
        List of trusted Nix users.
        CN: 信任的 Nix 用户列表（用于 `trusted-users` 设置）。
        EN: Users that are trusted by Nix (used in the `trusted-users` setting).
      '';
    };

    autoOptimise = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Automatically optimize the Nix store.
        CN: 是否自动优化 Nix 存储（例如减少碎片、整理路径）。
        EN: Automatically run store optimization steps; enabled by default.
      '';
    };

    autoGC = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Automatically run garbage collection.
        CN: 是否自动执行垃圾回收（nix store GC）。与其它自动 GC 工具（例如 nh.clean）可能冲突。
        EN: Enable automatic Nix garbage collection. May conflict with other auto-GC tools (e.g. nh.clean).
      '';
    };

    gcOptions = lib.mkOption {
      type = lib.types.str;
      default = "--delete-older-than 7d";
      description = ''
        Options passed to GC when automatic GC is enabled.
        CN: 自动 GC 时传递给 gc 的参数（例如保留时间）。
        EN: Command-line options for GC (e.g. retention period).
      '';
    };

    substituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "https://cache.nixos.org" ];
      description = ''
        List of binary cache substituters.
        CN: 二进制缓存替代源列表（substituters），用于加速构建与部署。
        EN: Binary cache substituters to fetch prebuilt packages.
      '';
    };

    trustedPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        List of trusted public keys for substituters.
        CN: 用于验证替代缓存的公钥列表（trusted-public-keys）。
        EN: Public keys trusted for verifying substituters.
      '';
    };
  };

  ####################################################################
  # Implementation: use config.modules.nix only
  ####################################################################
  config = lib.mkIf (cfg.enable) {
    # Nix settings applied from the chosen configuration
    nix = {
      settings = lib.mkIf cfg.enable {
        # Enable common experimental features used by this configuration set.
        experimental-features = [
          "flakes"
          "nix-command"
        ];

        # trusted users & binary caches
        "trusted-users" = cfg.trustedUsers;
        substituters = cfg.substituters;
        "trusted-public-keys" = cfg.trustedPublicKeys;
      };

      # Keep the original `optimise` option name for compatibility with other modules
      optimise = {
        automatic = cfg.autoOptimise;
      };

      # Automatic GC config (only enabled when autoGC is true)
      gc = lib.mkIf cfg.autoGC {
        automatic = true;
        # Weekly schedule by default; keep configurable through options.modules.nix.gcOptions if needed
        dates = "weekly";
        options = cfg.gcOptions;
      };
    };

    # nixpkgs.config intentionally left unset here. Configure `nixpkgs.config`
    # at flake / instance creation time (for example in `flake.nix` or when
    # creating the nixpkgs instance) to avoid external-instance conflicts.
    #
    # Setting `nixpkgs.config` inside a system module can lead to the error:
    # "Your system configures nixpkgs with an externally created instance."
    # Therefore we purposely do not set it here.
  };
}
