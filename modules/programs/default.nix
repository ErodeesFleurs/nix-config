/*
  nix-config/modules/programs/default.nix
  Programs modules aggregator — 程序/服务模块聚合

  CN:
  本文件将与“程序”或小型服务相关的子模块目录聚合为单一入口（例如 hyprland、gamescope、steam、nh、
  appimage、localsend、virt-manager、systemd 辅助工具等）。每个子模块应放在其各自子目录并包含一个 `default.nix`。
  采用统一模板以便于自动导入、审阅与 CI 验证。请将程序级别的开关与实现放到 modules/programs/<name>/default.nix。

  EN:
  Aggregates program- or small-service-related submodules into a single import point (for example: hyprland,
  gamescope, steam, nh, appimage, localsend, virt-manager, systemd helpers, etc.). Each submodule should live in
  its own directory and provide a `default.nix`. The uniform template allows automatic directory import, easier
  review and CI checks. Put program-level toggles and implementations under modules/programs/<name>/default.nix.
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
  # Import every submodule directory under `modules/programs` automatically.
  # 子目录中每个模块应包含 `default.nix`，并由此处统一导入。
  imports = fleursLib.importDir ./.;
}
