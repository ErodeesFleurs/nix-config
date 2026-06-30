{
  config,
  lib,
  pkgs,
  themeLib,
}:

let
  enabled = config.homeModules.dunst.enable;

  mkValueString =
    value:
    if builtins.isBool value then
      lib.boolToString value
    else if builtins.isInt value || builtins.isFloat value then
      toString value
    else if builtins.isString value then
      builtins.toJSON value
    else if builtins.isPath value then
      builtins.toJSON (toString value)
    else if builtins.isList value then
      lib.concatMapStringsSep "," mkValueString value
    else
      throw "Unsupported dunst setting value: ${builtins.toJSON value}";

  renderSection = name: values: ''
    [${name}]
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (key: value: "${key} = ${mkValueString value}") values
    )}
  '';

  settings = config.homeModules.dunst.settings;
  baseSections = {
    global = {
      follow = settings.global.follow;
      width = settings.global.width;
      height = settings.global.height;
      origin = settings.global.origin;
      alignment = "left";
      vertical_alignment = "center";
      ellipsize = "middle";
      offset = settings.global.offset;
      padding = settings.global.padding;
      horizontal_padding = settings.global.horizontal-padding;
      text_icon_padding = 16;
      icon_position = settings.global.icon-position;
      min_icon_size = settings.global.min-icon-size;
      max_icon_size = settings.global.max-icon-size;
      progress_bar_height = settings.global.progress-bar.height;
      progress_bar_frame_width = settings.global.progress-bar.frame-width;
      progress_bar_min_width = settings.global.progress-bar.min-width;
      progress_bar_max_width = settings.global.progress-bar.max-width;
      separator_height = 0;
      frame_width = settings.global.frame-width;
      frame_color = settings.global.frame-color;
      corner_radius = settings.global.corner-radius;
      transparency = 0;
      gap_size = settings.global.gap-size;
      line_height = 0;
      notification_limit = 0;
      idle_threshold = settings.global.idle-threshold;
      history_length = settings.global.history-length;
      show_age_threshold = 60;
      markup = "full";
      format = settings.global.format;
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
      mouse_left_click = settings.global.mouse-left-click;
      mouse_middle_click = settings.global.mouse-middle-click;
      mouse_right_click = settings.global.mouse-right-click;
    };

    experimental.per_monitor_dpi = false;

    urgency_low.timeout = settings.urgency.low.timeout;
    urgency_normal.timeout = settings.urgency.normal.timeout;
    urgency_critical.timeout = settings.urgency.critical.timeout;
  };

  template = lib.concatStringsSep "\n" (
    lib.mapAttrsToList renderSection (
      lib.recursiveUpdate baseSections {
        global = {
          frame_color = "@outline_variant@";
          highlight = "@primary@";
          separator_color = "frame";
        };

        urgency_low = {
          background = "@surface_container_low@";
          foreground = "@on_surface_variant@";
          frame_color = "@outline_variant@";
        };

        urgency_normal = {
          background = "@surface_container_high@";
          foreground = "@on_surface@";
          frame_color = "@outline_variant@";
        };

        urgency_critical = {
          background = "@error_container@";
          foreground = "@on_error_container@";
          frame_color = "@error@";
        };
      }
    )
  );
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/dunst" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = builtins.toFile "dunstrc.monet.in" template;
      target = "$out/dunst/dunstrc";
      inherit polarity;
      colors = [
        "surface_container_low"
        "surface_container_high"
        "on_surface"
        "on_surface_variant"
        "outline_variant"
        "primary"
        "error"
        "error_container"
        "on_error_container"
      ];
    };

  xdgPlaceholders = [
    { path = "dunst/dunstrc"; }
  ];

  links = [
    {
      name = "Dunst";
      target = ".config/dunst/dunstrc";
      source = "dunst/dunstrc";
      postLink = ''
        ${pkgs.dunst}/bin/dunstctl reload "$SOURCE" 2>/dev/null || ${pkgs.procps}/bin/pkill -HUP dunst 2>/dev/null || true
      '';
    }
  ];
}
