{ lib, ... }:

/*
  nix-config/modules/system/default.nix
  System modules aggregator — 系统模块聚合

  CN: 本文件将 system 相关子模块目录聚合为单一入口。每个子模块应放在自己的子目录内并包含一个 `default.nix`。
  EN: Aggregates system-related submodules. Each submodule lives in its own directory with a `default.nix`.

  This template uses a consistent header and `fleursLib.importDir` so all category index files have the same structure.
  该模板使用统一的头部与 `fleursLib.importDir` 导入方式，以保持各模块索引文件的风格一致。
*/

let
  fleursLib =
    lib.fleursLib or (import ../../lib {
      inherit lib;
      inputs = { };
    });
in
{
  # Compatibility forwarding has been removed. Submodules are imported directly from this directory.
  # The external compatibility shim is no longer imported here; callers should use the new module namespaces.
  # The legacy unified system option set has been migrated into focused submodules (e.g. `modules.nix`, `modules.etc`, `modules.filesystems`, `modules.network.*`).
  imports = fleursLib.importDir ./.;
}
