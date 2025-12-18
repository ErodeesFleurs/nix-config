/*
  nix-config/modules/system/systemd.nix
  Small systemd / program helpers — systemd 与小工具辅助模块

  CN: 本模块用于提供与 systemd 相关的轻量级程序开关与默认配置示例。
      当前以 `uwsm` 为示例提供一个可声明式的启用开关，并用中英双语注释说明用途。
  EN: This module exposes small helpers for systemd-related programs. It provides a
      declarative toggle for `uwsm` as an example, with bilingual (CN/EN) documentation.

  Notes:
  - Keep the module minimal: expose opt-in toggles and avoid hardcoding behavioural defaults
    beyond simple enable flags so host-specific configurations can override safely.
  - 本模块尽量保持精简：以可选开关为主，避免在模块内写死过多行为，便于主机关联配置覆盖。
*/

{ config, lib, ... }:

let
  cfg = config.modules.programs.systemd;
in
{
  options.modules.programs.systemd = {
    enable = lib.mkEnableOption "Small systemd/program helpers / systemd 小工具";

    uwsm = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Enable the uwsm program/service.

          CN: 启用 uwsm 程序/服务（如果系统包中存在该程序）。
          EN: Toggle to enable the uwsm program/service when available in system packages.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs = lib.mkIf cfg.uwsm.enable {
      uwsm = {
        enable = true;
      };
    };
  };
}
