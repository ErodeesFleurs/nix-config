{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.system.power;
in
{
  options.modules.system.power = {
    enable = lib.mkEnableOption "Power management configuration";

    enableTlp = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable TLP for advanced power management";
    };

    enablePowertop = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable powertop for power consumption analysis";
    };

    enableUpower = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable UPower for battery information";
    };

    cpuGovernor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "CPU frequency scaling governor";
      example = "powersave";
    };
  };

  config = lib.mkIf cfg.enable {
    # Basic power management
    powerManagement = {
      enable = true;
      cpuFreqGovernor = lib.mkIf (cfg.cpuGovernor != null) cfg.cpuGovernor;
      powertop = lib.mkIf cfg.enablePowertop {
        enable = true;
      };
    };

    # UPower for battery information
    services.upower = lib.mkIf cfg.enableUpower {
      enable = true;
    };

    # TLP for advanced power management
    services.tlp = lib.mkIf cfg.enableTlp {
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

    # Power management tools
    environment.systemPackages =
      with pkgs;
      [
        acpi
      ]
      ++ lib.optionals cfg.enableTlp [ tlp ];
  };
}
