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

    truncate-title-length = lib.mkOption {
      type = lib.types.int;
      default = 150;
      description = "Truncate window title after this length";
    };

    app-launcher-cmd = lib.mkOption {
      type = lib.types.str;
      default = "vicinae toggle";
      description = "Application launcher command";
    };

    clipboard-cmd = lib.mkOption {
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

    system-info = {
      indicators = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "Cpu"
          "Memory"
          "Temperature"
        ];
        description = "System info indicators to show";
      };

      cpu-warn-threshold = lib.mkOption {
        type = lib.types.int;
        default = 70;
        description = "CPU warning threshold percentage";
      };

      cpu-alert-threshold = lib.mkOption {
        type = lib.types.int;
        default = 85;
        description = "CPU alert threshold percentage";
      };

      memory-warn-threshold = lib.mkOption {
        type = lib.types.int;
        default = 70;
        description = "Memory warning threshold percentage";
      };

      memory-alert-threshold = lib.mkOption {
        type = lib.types.int;
        default = 85;
        description = "Memory alert threshold percentage";
      };

      temperature-warn-threshold = lib.mkOption {
        type = lib.types.int;
        default = 70;
        description = "Temperature warning threshold";
      };

      temperature-alert-threshold = lib.mkOption {
        type = lib.types.int;
        default = 85;
        description = "Temperature alert threshold";
      };

      disk-warn-threshold = lib.mkOption {
        type = lib.types.int;
        default = 80;
        description = "Disk warning threshold percentage";
      };

      disk-alert-threshold = lib.mkOption {
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
      lock-cmd = lib.mkOption {
        type = lib.types.str;
        default = "hyprlock &";
        description = "Lock screen command";
      };

      wifi-more-cmd = lib.mkOption {
        type = lib.types.str;
        default = "nm-connection-editor";
        description = "WiFi settings command";
      };

      vpn-more-cmd = lib.mkOption {
        type = lib.types.str;
        default = "nm-connection-editor";
        description = "VPN settings command";
      };
    };

    appearance = {
      font-name = lib.mkOption {
        type = lib.types.str;
        default = "CaskaydiaMonoNerdFont";
        description = "Font name";
      };

      style = lib.mkOption {
        type = lib.types.str;
        default = "Islands";
        description = "Bar style";
      };

      menu-backdrop = lib.mkOption {
        type = lib.types.float;
        default = 0.0;
        description = "Menu backdrop opacity";
      };
    };

    custom-modules = lib.mkOption {
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

    extra-settings = lib.mkOption {
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
          truncate_title_after_length = cfg.truncate-title-length;
          app_launcher_cmd = cfg.app-launcher-cmd;
          clipboard_cmd = cfg.clipboard-cmd;

          modules = {
            left = cfg.modules.left;
            center = cfg.modules.center;
            right = cfg.modules.right;
          };

          system_info = {
            indicators = cfg.system-info.indicators;
            cpu = {
              warn_threshold = cfg.system-info.cpu-warn-threshold;
              alert_threshold = cfg.system-info.cpu-alert-threshold;
            };
            memory = {
              warn_threshold = cfg.system-info.memory-warn-threshold;
              alert_threshold = cfg.system-info.memory-alert-threshold;
            };
            temperature = {
              warn_threshold = cfg.system-info.temperature-warn-threshold;
              alert_threshold = cfg.system-info.temperature-alert-threshold;
            };
            disk = {
              warn_threshold = cfg.system-info.disk-warn-threshold;
              alert_threshold = cfg.system-info.disk-alert-threshold;
            };
          };

          clock = {
            format = cfg.clock.format;
          };

          settings = {
            lock_cmd = cfg.settings.lock-cmd;
            wifi_more_cmd = cfg.settings.wifi-more-cmd;
            vpn_more_cmd = cfg.settings.vpn-more-cmd;
          };

          appearance = {
            font_name = cfg.appearance.font-name;
            style = cfg.appearance.style;
            menu = {
              backdrop = cfg.appearance.menu-backdrop;
            };
          };

          CustomModule = cfg.custom-modules;
        }
        cfg.extra-settings
      ];
    };
  };
}
