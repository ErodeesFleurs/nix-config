{ config, lib, ... }:

let
  # Use the explicit `modules.filesystems` namespace.
  cfg = config.modules.filesystems or { };
in
{
  # Options for filesystem extras: hosts and other modules can add entries here.
  options.modules.filesystems = {
    extra = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Extra `fileSystems` entries to be merged into the final system `fileSystems` set.
        CN: 额外的 `fileSystems` 条目（attrset），会合并到最终的 `fileSystems` 中。
      '';
    };
    enable = lib.mkEnableOption "Filesystems helper / 文件系统辅助模块";
  };

  # When enabled, merge provided extras into top-level fileSystems.
  config = lib.mkIf cfg.enable {
    fileSystems = lib.mkMerge [ cfg.extra ];
  };
}
