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

        horizontalPadding = lib.mkOption {
          type = lib.types.int;
          default = 15;
          description = "Horizontal padding";
        };

        cornerRadius = lib.mkOption {
          type = lib.types.int;
          default = 8;
          description = "Corner radius of notification window";
        };

        frameWidth = lib.mkOption {
          type = lib.types.int;
          default = 2;
          description = "Width of notification frame";
        };

        frameColor = lib.mkOption {
          type = lib.types.str;
          default = "#313244";
          description = "Color of notification frame";
        };

        gapSize = lib.mkOption {
          type = lib.types.int;
          default = 8;
          description = "Gap between notifications";
        };

        iconPosition = lib.mkOption {
          type = lib.types.str;
          default = "left";
          description = "Position of icon (left, right, off)";
        };

        minIconSize = lib.mkOption {
          type = lib.types.int;
          default = 48;
          description = "Minimum icon size";
        };

        maxIconSize = lib.mkOption {
          type = lib.types.int;
          default = 64;
          description = "Maximum icon size";
        };

        progressBar = {
          height = lib.mkOption {
            type = lib.types.int;
            default = 8;
            description = "Height of progress bar";
          };

          frameWidth = lib.mkOption {
            type = lib.types.int;
            default = 1;
            description = "Frame width of progress bar";
          };

          minWidth = lib.mkOption {
            type = lib.types.int;
            default = 150;
            description = "Minimum width of progress bar";
          };

          maxWidth = lib.mkOption {
            type = lib.types.int;
            default = 300;
            description = "Maximum width of progress bar";
          };
        };

        idleThreshold = lib.mkOption {
          type = lib.types.int;
          default = 120;
          description = "Idle threshold in seconds";
        };

        historyLength = lib.mkOption {
          type = lib.types.int;
          default = 20;
          description = "Maximum number of notifications to keep in history";
        };

        format = lib.mkOption {
          type = lib.types.str;
          default = "<b>%s</b>\\n%b";
          description = "Format string for notifications";
        };

        mouseLeftClick = lib.mkOption {
          type = lib.types.str;
          default = "do_action";
          description = "Action on left mouse click";
        };

        mouseMiddleClick = lib.mkOption {
          type = lib.types.str;
          default = "close_all";
          description = "Action on middle mouse click";
        };

        mouseRightClick = lib.mkOption {
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

          highlight = lib.mkOption {
            type = lib.types.str;
            default = "#cba6f7";
            description = "Highlight color for normal urgency";
          };
        };

        critical = {
          timeout = lib.mkOption {
            type = lib.types.int;
            default = 0;
            description = "Timeout for critical urgency notifications (0 = no timeout)";
          };

          highlight = lib.mkOption {
            type = lib.types.str;
            default = "#cba6f7";
            description = "Highlight color for critical urgency";
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
          horizontal_padding = cfg.settings.global.horizontalPadding;
          text_icon_padding = 15;
          icon_position = cfg.settings.global.iconPosition;
          min_icon_size = cfg.settings.global.minIconSize;
          max_icon_size = cfg.settings.global.maxIconSize;
          progress_bar_height = cfg.settings.global.progressBar.height;
          progress_bar_frame_width = cfg.settings.global.progressBar.frameWidth;
          progress_bar_min_width = cfg.settings.global.progressBar.minWidth;
          progress_bar_max_width = cfg.settings.global.progressBar.maxWidth;
          separator_height = 2;
          frame_width = cfg.settings.global.frameWidth;
          frame_color = cfg.settings.global.frameColor;
          corner_radius = cfg.settings.global.cornerRadius;
          transparency = 0;
          gap_size = cfg.settings.global.gapSize;
          line_height = 0;
          notification_limit = 0;
          idle_threshold = cfg.settings.global.idleThreshold;
          history_length = cfg.settings.global.historyLength;
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
          mouse_left_click = cfg.settings.global.mouseLeftClick;
          mouse_middle_click = cfg.settings.global.mouseMiddleClick;
          mouse_right_click = cfg.settings.global.mouseRightClick;
        };

        experimental = {
          per_monitor_dpi = false;
        };

        urgency_low = {
          timeout = cfg.settings.urgency.low.timeout;
        };

        urgency_normal = {
          highlight = cfg.settings.urgency.normal.highlight;
          timeout = cfg.settings.urgency.normal.timeout;
        };

        urgency_critical = {
          highlight = cfg.settings.urgency.critical.highlight;
          timeout = cfg.settings.urgency.critical.timeout;
        };
      };
    };
  };
}
