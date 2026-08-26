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

    # 单一数据源：同时应用于 services.dunst.settings 与 monet 主题模板
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        global = {
          follow = "none";
          width = 360;
          height = 145;
          origin = "top-right";
          alignment = "left";
          vertical_alignment = "center";
          ellipsize = "middle";
          offset = "15x15";
          padding = 20;
          horizontal_padding = 20;
          text_icon_padding = 16;
          icon_position = "left";
          min_icon_size = 48;
          max_icon_size = 64;
          progress_bar_height = 6;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;
          separator_height = 0;
          frame_width = 1;
          frame_color = "#79747e";
          corner_radius = 24;
          transparency = 0;
          gap_size = 12;
          line_height = 0;
          notification_limit = 0;
          idle_threshold = 120;
          history_length = 20;
          show_age_threshold = 60;
          markup = "full";
          format = "<b>%s</b>\n%b";
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
          mouse_left_click = "do_action";
          mouse_middle_click = "close_all";
          mouse_right_click = "close_current";
        };

        experimental = {
          per_monitor_dpi = false;
        };

        urgency_low = {
          timeout = 4;
        };

        urgency_normal = {
          timeout = 6;
        };

        urgency_critical = {
          timeout = 0;
        };
      };
      description = "Dunst settings table (single source of truth).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = cfg.settings;
    };
  };
}
