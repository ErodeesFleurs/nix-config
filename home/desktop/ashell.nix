{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.ashell;
in
{
  options.homeModules.ashell = {
    enable = lib.mkEnableOption "Ashell desktop shell";

    systemd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable systemd integration";
    };

    outputs = lib.mkOption {
      type = lib.types.str;
      default = "All";
      description = "Outputs to display on";
    };

    position = lib.mkOption {
      type = lib.types.enum [
        "Top"
        "Bottom"
        "Left"
        "Right"
      ];
      default = "Top";
      description = "Bar position";
    };

    truncateTitleLength = lib.mkOption {
      type = lib.types.int;
      default = 150;
      description = "Truncate window title after this length";
    };

    appLauncherCmd = lib.mkOption {
      type = lib.types.str;
      default = "vicinae toggle";
      description = "Application launcher command";
    };

    clipboardCmd = lib.mkOption {
      type = lib.types.str;
      default = "cliphist-rofi-img | wl-copy";
      description = "Clipboard manager command";
    };

    modules = {
      left = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str));
        default = [
          "appLauncher"
          "Workspaces"
        ];
        description = "Left modules";
      };

      center = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "WindowTitle" ];
        description = "Center modules";
      };

      right = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str));
        default = [
          "Tray"
          "SystemInfo"
          [
            "Clock"
            "Privacy"
            "Settings"
          ]
        ];
        description = "Right modules";
      };
    };

    systemInfo = {
      indicators = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "Cpu"
          "Memory"
          "Temperature"
        ];
        description = "System info indicators to show";
      };

      cpuWarnThreshold = lib.mkOption {
        type = lib.types.int;
        default = 70;
        description = "CPU warning threshold percentage";
      };

      cpuAlertThreshold = lib.mkOption {
        type = lib.types.int;
        default = 85;
        description = "CPU alert threshold percentage";
      };

      memoryWarnThreshold = lib.mkOption {
        type = lib.types.int;
        default = 70;
        description = "Memory warning threshold percentage";
      };

      memoryAlertThreshold = lib.mkOption {
        type = lib.types.int;
        default = 85;
        description = "Memory alert threshold percentage";
      };

      temperatureWarnThreshold = lib.mkOption {
        type = lib.types.int;
        default = 70;
        description = "Temperature warning threshold";
      };

      temperatureAlertThreshold = lib.mkOption {
        type = lib.types.int;
        default = 85;
        description = "Temperature alert threshold";
      };

      diskWarnThreshold = lib.mkOption {
        type = lib.types.int;
        default = 80;
        description = "Disk warning threshold percentage";
      };

      diskAlertThreshold = lib.mkOption {
        type = lib.types.int;
        default = 90;
        description = "Disk alert threshold percentage";
      };
    };

    clock = {
      format = lib.mkOption {
        type = lib.types.str;
        default = "%a %d %b %R";
        description = "Clock format string";
      };
    };

    settings = {
      lockCmd = lib.mkOption {
        type = lib.types.str;
        default = "hyprlock &";
        description = "Lock screen command";
      };

      wifiMoreCmd = lib.mkOption {
        type = lib.types.str;
        default = "nm-connection-editor";
        description = "WiFi settings command";
      };

      vpnMoreCmd = lib.mkOption {
        type = lib.types.str;
        default = "nm-connection-editor";
        description = "VPN settings command";
      };
    };

    appearance = {
      fontName = lib.mkOption {
        type = lib.types.str;
        default = "CaskaydiaMonoNerdFont";
        description = "Font name";
      };

      style = lib.mkOption {
        type = lib.types.str;
        default = "Islands";
        description = "Bar style";
      };

      menuBackdrop = lib.mkOption {
        type = lib.types.float;
        default = 0.0;
        description = "Menu backdrop opacity";
      };
    };

    customModules = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [
        {
          name = "appLauncher";
          icon = "";
          command = "vicinae toggle";
        }
      ];
      description = "Custom modules";
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional settings";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ashell = {
      enable = true;
      systemd.enable = cfg.systemd;
      settings = lib.mkMerge [
        {
          outputs = cfg.outputs;
          position = cfg.position;
          truncate_title_after_length = cfg.truncateTitleLength;
          app_launcher_cmd = cfg.appLauncherCmd;
          clipboard_cmd = cfg.clipboardCmd;

          modules = {
            left = cfg.modules.left;
            center = cfg.modules.center;
            right = cfg.modules.right;
          };

          system_info = {
            indicators = cfg.systemInfo.indicators;
            cpu = {
              warn_threshold = cfg.systemInfo.cpuWarnThreshold;
              alert_threshold = cfg.systemInfo.cpuAlertThreshold;
            };
            memory = {
              warn_threshold = cfg.systemInfo.memoryWarnThreshold;
              alert_threshold = cfg.systemInfo.memoryAlertThreshold;
            };
            temperature = {
              warn_threshold = cfg.systemInfo.temperatureWarnThreshold;
              alert_threshold = cfg.systemInfo.temperatureAlertThreshold;
            };
            disk = {
              warn_threshold = cfg.systemInfo.diskWarnThreshold;
              alert_threshold = cfg.systemInfo.diskAlertThreshold;
            };
          };

          clock = {
            format = cfg.clock.format;
          };

          settings = {
            lock_cmd = cfg.settings.lockCmd;
            wifi_more_cmd = cfg.settings.wifiMoreCmd;
            vpn_more_cmd = cfg.settings.vpnMoreCmd;
          };

          appearance = {
            font_name = cfg.appearance.fontName;
            style = cfg.appearance.style;
            menu = {
              backdrop = cfg.appearance.menuBackdrop;
            };
          };

          CustomModule = cfg.customModules;
        }
        cfg.extraSettings
      ];
    };
  };
}
