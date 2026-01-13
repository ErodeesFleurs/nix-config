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
    enable = lib.mkEnableOption "nh（Nix 辅助工具）";

    clean = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          启用 nh 的自动清理功能。
          注意：此选项与 `nix.gc.automatic` 可能冲突，请仅启用其中一个以避免重复或并发的垃圾回收操作。
        '';
      };

      extra-args = lib.mkOption {
        type = lib.types.str;
        default = "--keep-since 3d --keep 2";
        description = ''
          传递给 `nh clean` 的额外命令行参数，默认为 "--keep-since 3d --keep 2"。
        '';
      };
    };

    flake = lib.mkOption {
      type = lib.types.str;
      default = "/home/fleurs/nix-config";
      description = ''
        nh 使用的 flake 配置路径，默认指向当前仓库。
      '';
      example = lib.literalExpression "/home/fleurs/nix-config";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;

      clean = lib.mkIf cfg.clean.enable {
        enable = true;
        extraArgs = cfg.clean.extra-args;
      };

      flake = cfg.flake;
    };

    warnings = lib.optional (cfg.clean.enable && (config.nix.gc.automatic or false)) [
      "nh.clean 与 nix.gc.automatic 同时启用，可能导致冲突，请禁用其中一项。"
    ];
  };
}
