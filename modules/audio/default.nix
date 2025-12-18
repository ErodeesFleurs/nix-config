/*
  nix-config/modules/audio/default.nix
  Audio modules aggregator — 音频模块聚合

  CN: 本文件将音频相关的子模块目录聚合为单一入口。每个子模块应放在自己的子目录内并包含一个 `default.nix`。
  EN: Aggregates audio-related submodules. Each submodule lives in its own directory with a `default.nix`.
  模板以统一的头部和导入方式（fleursLib.importDir）保证风格一致性。
*/

{ lib, ... }:

let
  fleursLib =
    lib.fleursLib or (import ../../lib {
      inherit lib;
      inputs = { };
    });
in
{
  imports = fleursLib.importDir ./.;
}
