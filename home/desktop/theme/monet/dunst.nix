{
  config,
  lib,
  pkgs,
}:

let
  enabled = config.homeModules.dunst.enable;
  homeDir = config.home.homeDirectory;
  currentSymlink = "${homeDir}/.local/share/themes/current";

  mkValueString =
    value:
    if builtins.isBool value then
      lib.boolToString value
    else if builtins.isInt value || builtins.isFloat value then
      toString value
    else if builtins.isString value then
      value
    else if builtins.isPath value then
      toString value
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
      text_icon_padding = 15;
      icon_position = settings.global.icon-position;
      min_icon_size = settings.global.min-icon-size;
      max_icon_size = settings.global.max-icon-size;
      progress_bar_height = settings.global.progress-bar.height;
      progress_bar_frame_width = settings.global.progress-bar.frame-width;
      progress_bar_min_width = settings.global.progress-bar.min-width;
      progress_bar_max_width = settings.global.progress-bar.max-width;
      separator_height = 2;
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
          frame_color = "__M3_OUTLINE__";
          highlight = "__M3_PRIMARY__";
          separator_color = "frame";
        };

        urgency_low = {
          background = "__M3_SURFACE_CONTAINER__";
          foreground = "__M3_ON_SURFACE_VARIANT__";
          frame_color = "__M3_OUTLINE__";
        };

        urgency_normal = {
          background = "__M3_SURFACE__";
          foreground = "__M3_ON_SURFACE__";
          frame_color = "__M3_PRIMARY__";
        };

        urgency_critical = {
          background = "__M3_ERROR_CONTAINER__";
          foreground = "__M3_ON_ERROR_CONTAINER__";
          frame_color = "__M3_ERROR__";
        };
      }
    )
  );
in
{
  enable = enabled;
  outputDirs = [ "$out/dunst" ];

  generate =
    { polarity }:
    ''
      cat > "$out/dunst/dunstrc" << 'DUNSTEOF'
      ${template}
      DUNSTEOF

      substituteInPlace "$out/dunst/dunstrc" \
        --replace-fail __M3_SURFACE__ "$(jq -r '.colors.surface["${polarity}"].color' colors.json)" \
        --replace-fail __M3_SURFACE_CONTAINER__ "$(jq -r '.colors.surface_container["${polarity}"].color' colors.json)" \
        --replace-fail __M3_ON_SURFACE__ "$(jq -r '.colors.on_surface["${polarity}"].color' colors.json)" \
        --replace-fail __M3_ON_SURFACE_VARIANT__ "$(jq -r '.colors.on_surface_variant["${polarity}"].color' colors.json)" \
        --replace-fail __M3_OUTLINE__ "$(jq -r '.colors.outline["${polarity}"].color' colors.json)" \
        --replace-fail __M3_PRIMARY__ "$(jq -r '.colors.primary["${polarity}"].color' colors.json)" \
        --replace-fail __M3_ERROR__ "$(jq -r '.colors.error["${polarity}"].color' colors.json)" \
        --replace-fail __M3_ERROR_CONTAINER__ "$(jq -r '.colors.error_container["${polarity}"].color' colors.json)" \
        --replace-fail __M3_ON_ERROR_CONTAINER__ "$(jq -r '.colors.on_error_container["${polarity}"].color' colors.json)"
    '';

  xdgConfig."dunst/dunstrc".force = lib.mkForce true;

  activation.linkDunstTheme =
    lib.hm.dag.entryAfter [ "initThemeLinks" "cleanupDarkmanLegacyHooks" ]
      ''
        DUNST_CONFIG="${homeDir}/.config/dunst/dunstrc"
        THEME_DUNST="${currentSymlink}/dunst/dunstrc"

        if [ -d "$(dirname "$DUNST_CONFIG")" ] && [ -f "$THEME_DUNST" ]; then
          $DRY_RUN_CMD rm -f "$DUNST_CONFIG"
          $DRY_RUN_CMD ln -sfn "$THEME_DUNST" "$DUNST_CONFIG"
          ${pkgs.dunst}/bin/dunstctl reload 2>/dev/null || ${pkgs.procps}/bin/pkill -HUP dunst 2>/dev/null || true
        fi
      '';
}
