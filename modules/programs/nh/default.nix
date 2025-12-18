/*
  nix-config/modules/system/nh.nix
  nh module — Nix helper utilities (nh)

  CN: 本模块为 nh（Nix Helper）提供声明式配置接口，例如自动清理选项与 flake 路径。
  EN: This module exposes declarative configuration for the `nh` helper utility, e.g.
      automatic cleanup and flake path settings.

  说明:
  - 保持原有行为与选项名称不变，仅增强文档、注释为中英双语并整理结构。
  - 当同时启用 nh.clean 和 nix.gc.automatic 时，模块会发出警告（避免冲突）。
*/

{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.programs.nh;
in
{
  options.modules.programs.nh = {
    enable = lib.mkEnableOption "nh (Nix helper tool) / nh（Nix 辅助工具）";

    clean = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable automatic cleanup with nh.

          CN: 启用 nh 的自动清理功能。
          EN: Enable automatic garbage/closure cleanup provided by nh.

          Note: This conflicts with `nix.gc.automatic`. Only enable one of them to avoid
          duplicate/concurrent GC runs.
          注意：此选项与 `nix.gc.automatic` 可能冲突，请仅启用其中一个以避免重复或并发的垃圾回收操作。
        '';
      };

      extraArgs = lib.mkOption {
        type = lib.types.str;
        default = "--keep-since 3d --keep 2";
        description = ''
          Extra arguments passed to `nh clean`.

          CN: 传递给 `nh clean` 的额外命令行参数，默认为 "--keep-since 3d --keep 2"。
          EN: Extra CLI args for `nh clean` (default: "--keep-since 3d --keep 2").
        '';
      };
    };

    flake = lib.mkOption {
      type = lib.types.str;
      default = "/home/fleurs/nix-config";
      description = ''
        Path to the flake configuration used by nh.

        CN: nh 使用的 flake 配置路径，默认指向当前仓库。
        EN: Path to the flake to operate on (used by nh commands that expect a flake).
      '';
      example = lib.literalExpression "/home/fleurs/nix-config";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;

      # Configure automatic cleaning if requested
      clean = lib.mkIf cfg.clean.enable {
        enable = true;
        extraArgs = cfg.clean.extraArgs;
      };

      # Flake path consumed by nh
      flake = cfg.flake;
    };

    # Warn the user if both nh.clean and nix.gc.automatic are enabled to avoid conflict.
    warnings =
      lib.optional (cfg.clean.enable && config.nix.gc.automatic or false)
        "Both nh.clean and nix.gc.automatic are enabled. This may cause conflicts. Please disable one of them. / CN: nh.clean 与 nix.gc.automatic 同时启用，可能导致冲突，请禁用其中一项。";
  };
}
