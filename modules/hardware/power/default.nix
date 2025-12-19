/*
  nix-config/modules/system/power.nix
  电源与省电配置模块 — Power management module

  CN: 该模块为系统电源相关配置提供集中化选项，包括 TLP、powertop、UPower 及 CPU 调频策略。
  EN: This module centralizes power-related configuration for the system, including TLP, powertop,
      UPower and CPU frequency governor settings.

  说明：
  - 保持默认行为不变，仅补充中英文注释并整理选项说明与系统包列表。
  - 尽量不改变原有逻辑（例如 cpuFreqGovernor 的赋值方式保留原样以避免意外副作用）。
*/

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.hardware.power;
in
{
  options.modules.hardware.power = {
    enable = lib.mkEnableOption "Power management configuration / 电源管理配置";

    enable-tlp = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        启用 TLP 以获得更细粒度的电源管理（针对笔记本/节能场景）。
      '';
    };

    enable-powertop = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        启用 powertop，用于分析与调优电源消耗（通常以命令行或交互方式运行）。
      '';
    };

    enable-upower = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        启用 UPower 服务，用于提供电池状态等信息（桌面环境与电源小工具通常依赖）。
      '';
    };

    cpu-governor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        指定 CPU 调频策略（例如 \"powersave\" 或 \"performance\"）。为 null 时不强制设置。
      '';
      example = "powersave";
    };
  };

  config = lib.mkIf cfg.enable {
    # Basic power management
    powerManagement = {
      enable = true;
      # Note: keep the original conditional assignment style to avoid changing semantics.
      cpuFreqGovernor = lib.mkIf (cfg.cpu-governor != null) cfg.cpu-governor;
      powertop = lib.mkIf cfg.enable-powertop {
        enable = true;
      };
    };

    # UPower for battery information
    services.upower = lib.mkIf cfg.enable-upower {
      enable = true;
    };

    # TLP for advanced power management
    services.tlp = lib.mkIf cfg.enable-tlp {
      enable = true;
      settings = {
        # CPU settings
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 30;

        # Boost settings
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;

        # Platform profile
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        # Runtime PM
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";

        # USB autosuspend
        USB_AUTOSUSPEND = 1;

        # Battery thresholds (if supported)
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    # Power management tools: ensure common utilities are available.
    # CN: 将常用工具放入 systemPackages，便于在无网络或恢复模式下使用。
    environment.systemPackages =
      with pkgs;
      [
        acpi
      ]
      # Include powertop and tlp packages conditionally according to the enabled options.
      ++ lib.optionals cfg.enable-powertop [ powertop ]
      ++ lib.optionals cfg.enable-tlp [ tlp ];
  };
}
