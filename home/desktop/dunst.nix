{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.dunst;
in
{
  options.homeModules.dunst = {
    enable = lib.mkEnableOption "Dunst notification daemon";

    settings = {
      global = {
        follow = lib.mkOption {
          type = lib.types.str;
          default = "none";
          description = "Follow mouse, keyboard or none";
        };

        width = lib.mkOption {
          type = lib.types.int;
          default = 300;
          description = "Width of notification window";
        };

        height = lib.mkOption {
          type = lib.types.int;
          default = 145;
          description = "Height of notification window";
        };

        origin = lib.mkOption {
          type = lib.types.str;
          default = "top-right";
          description = "Position of notification (top-right, top-left, etc.)";
        };

        offset = lib.mkOption {
          type = lib.types.str;
          default = "15x15";
          description = "Offset from the origin";
        };

        padding = lib.mkOption {
          type = lib.types.int;
          default = 15;
          description = "Padding between text and separator";
        };

        horizontal-padding = lib.mkOption {
          type = lib.types.int;
          default = 15;
          description = "Horizontal padding";
        };

        corner-radius = lib.mkOption {
          type = lib.types.int;
          default = 8;
          description = "Corner radius of notification window";
        };

        frame-width = lib.mkOption {
          type = lib.types.int;
          default = 2;
          description = "Width of notification frame";
        };

        frame-color = lib.mkOption {
          type = lib.types.str;
          default = "#313244";
          description = "Color of notification frame";
        };

        gap-size = lib.mkOption {
          type = lib.types.int;
          default = 8;
          description = "Gap between notifications";
        };

        icon-position = lib.mkOption {
          type = lib.types.str;
          default = "left";
          description = "Position of icon (left, right, off)";
        };

        min-icon-size = lib.mkOption {
          type = lib.types.int;
          default = 48;
          description = "Minimum icon size";
        };

        max-icon-size = lib.mkOption {
          type = lib.types.int;
          default = 64;
          description = "Maximum icon size";
        };

        progress-bar = {
          height = lib.mkOption {
            type = lib.types.int;
            default = 8;
            description = "Height of progress bar";
          };

          frame-width = lib.mkOption {
            type = lib.types.int;
            default = 1;
            description = "Frame width of progress bar";
          };

          min-width = lib.mkOption {
            type = lib.types.int;
            default = 150;
            description = "Minimum width of progress bar";
          };

          max-width = lib.mkOption {
            type = lib.types.int;
            default = 300;
            description = "Maximum width of progress bar";
          };
        };

        idle-threshold = lib.mkOption {
          type = lib.types.int;
          default = 120;
          description = "Idle threshold in seconds";
        };

        history-length = lib.mkOption {
          type = lib.types.int;
          default = 20;
          description = "Maximum number of notifications to keep in history";
        };

        format = lib.mkOption {
          type = lib.types.str;
          default = "<b>%s</b>\\n%b";
          description = "Format string for notifications";
        };

        mouse-left-click = lib.mkOption {
          type = lib.types.str;
          default = "do_action";
          description = "Action on left mouse click";
        };

        mouse-middle-click = lib.mkOption {
          type = lib.types.str;
          default = "close_all";
          description = "Action on middle mouse click";
        };

        mouse-right-click = lib.mkOption {
          type = lib.types.str;
          default = "close_current";
          description = "Action on right mouse click";
        };
      };

      urgency = {
        low = {
          timeout = lib.mkOption {
            type = lib.types.int;
            default = 4;
            description = "Timeout for low urgency notifications";
          };
        };

        normal = {
          timeout = lib.mkOption {
            type = lib.types.int;
            default = 6;
            description = "Timeout for normal urgency notifications";
          };
        };

        critical = {
          timeout = lib.mkOption {
            type = lib.types.int;
            default = 0;
            description = "Timeout for critical urgency notifications (0 = no timeout)";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          follow = cfg.settings.global.follow;
          width = cfg.settings.global.width;
          height = cfg.settings.global.height;
          origin = cfg.settings.global.origin;
          alignment = "left";
          vertical_alignment = "center";
          ellipsize = "middle";
          offset = cfg.settings.global.offset;
          padding = cfg.settings.global.padding;
          horizontal_padding = cfg.settings.global.horizontal-padding;
          text_icon_padding = 15;
          icon_position = cfg.settings.global.icon-position;
          min_icon_size = cfg.settings.global.min-icon-size;
          max_icon_size = cfg.settings.global.max-icon-size;
          progress_bar_height = cfg.settings.global.progress-bar.height;
          progress_bar_frame_width = cfg.settings.global.progress-bar.frame-width;
          progress_bar_min_width = cfg.settings.global.progress-bar.min-width;
          progress_bar_max_width = cfg.settings.global.progress-bar.max-width;
          separator_height = 2;
          frame_width = cfg.settings.global.frame-width;
          frame_color = cfg.settings.global.frame-color;
          corner_radius = cfg.settings.global.corner-radius;
          transparency = 0;
          gap_size = cfg.settings.global.gap-size;
          line_height = 0;
          notification_limit = 0;
          idle_threshold = cfg.settings.global.idle-threshold;
          history_length = cfg.settings.global.history-length;
          show_age_threshold = 60;
          markup = "full";
          format = cfg.settings.global.format;
          word_wrap = "yes";
          sort = "yes";
          shrink = "no";
          indicate_hidden = "yes";
          sticky_history = "yes";
          ignore_newline = "no";
          show_indicators = "no";
          stack_duplicates = true;
          always_run_script = true;
          hide_duplicate_count = false;
          ignore_dbusclose = false;
          force_xwayland = false;
          force_xinerama = false;
          mouse_left_click = cfg.settings.global.mouse-left-click;
          mouse_middle_click = cfg.settings.global.mouse-middle-click;
          mouse_right_click = cfg.settings.global.mouse-right-click;
        };

        experimental = {
          per_monitor_dpi = false;
        };

        urgency_low = {
          timeout = cfg.settings.urgency.low.timeout;
        };

        urgency_normal = {
          timeout = cfg.settings.urgency.normal.timeout;
        };

        urgency_critical = {
          timeout = cfg.settings.urgency.critical.timeout;
        };
      };
    };
  };
}
