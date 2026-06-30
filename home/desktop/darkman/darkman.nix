{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-modules.desktop.darkman;
  homeDir = config.home.homeDirectory;
  shellArg = value: lib.escapeShellArg (toString value);
  wallpaperArg = wallpaper: if wallpaper == null then "''" else shellArg wallpaper;

  # ── 主题文件基础路径 ────────────────────────────
  themeBase = "${homeDir}/.local/share/themes";
  currentSymlink = "${themeBase}/current";

  m3LightWaybarCss = builtins.readFile ../../../assets/waybar/m3-expressive-light.css;
  m3DarkWaybarCss = builtins.readFile ../../../assets/waybar/m3-expressive-dark.css;
  m3WaybarBodyCssPath = ../../../assets/waybar/m3-expressive-body.css;
  dunstEnabled = config.homeModules.dunst.enable;
  btopEnabled = config.homeModules.terminal.btop.enable;
  ghosttyEnabled = config.programs.ghostty.enable;
  mkDunstValueString =
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
      lib.concatMapStringsSep "," mkDunstValueString value
    else
      throw "Unsupported dunst setting value: ${builtins.toJSON value}";
  dunstRenderSection = name: values: ''
    [${name}]
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (key: value: "${key} = ${mkDunstValueString value}") values
    )}
  '';
  dunstModuleSettings = config.homeModules.dunst.settings;
  dunstBaseSections = {
    global = {
      follow = dunstModuleSettings.global.follow;
      width = dunstModuleSettings.global.width;
      height = dunstModuleSettings.global.height;
      origin = dunstModuleSettings.global.origin;
      alignment = "left";
      vertical_alignment = "center";
      ellipsize = "middle";
      offset = dunstModuleSettings.global.offset;
      padding = dunstModuleSettings.global.padding;
      horizontal_padding = dunstModuleSettings.global.horizontal-padding;
      text_icon_padding = 15;
      icon_position = dunstModuleSettings.global.icon-position;
      min_icon_size = dunstModuleSettings.global.min-icon-size;
      max_icon_size = dunstModuleSettings.global.max-icon-size;
      progress_bar_height = dunstModuleSettings.global.progress-bar.height;
      progress_bar_frame_width = dunstModuleSettings.global.progress-bar.frame-width;
      progress_bar_min_width = dunstModuleSettings.global.progress-bar.min-width;
      progress_bar_max_width = dunstModuleSettings.global.progress-bar.max-width;
      separator_height = 2;
      frame_width = dunstModuleSettings.global.frame-width;
      frame_color = dunstModuleSettings.global.frame-color;
      corner_radius = dunstModuleSettings.global.corner-radius;
      transparency = 0;
      gap_size = dunstModuleSettings.global.gap-size;
      line_height = 0;
      notification_limit = 0;
      idle_threshold = dunstModuleSettings.global.idle-threshold;
      history_length = dunstModuleSettings.global.history-length;
      show_age_threshold = 60;
      markup = "full";
      format = dunstModuleSettings.global.format;
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
      mouse_left_click = dunstModuleSettings.global.mouse-left-click;
      mouse_middle_click = dunstModuleSettings.global.mouse-middle-click;
      mouse_right_click = dunstModuleSettings.global.mouse-right-click;
    };

    experimental = {
      per_monitor_dpi = false;
    };

    urgency_low = {
      timeout = dunstModuleSettings.urgency.low.timeout;
    };

    urgency_normal = {
      timeout = dunstModuleSettings.urgency.normal.timeout;
    };

    urgency_critical = {
      timeout = dunstModuleSettings.urgency.critical.timeout;
    };
  };
  dunstMonetTemplate = lib.concatStringsSep "\n" (
    lib.mapAttrsToList dunstRenderSection (
      lib.recursiveUpdate dunstBaseSections {
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

  # ── 构建一个 polarity 变体的所有主题文件 ────────
  mkThemeDerivation =
    {
      polarity,
      waybarCss,
      wallpaper,
      qt5ctStyle,
    }:
    pkgs.runCommand "darkman-theme-${polarity}"
      {
        nativeBuildInputs = [ pkgs.jq ];
      }
      ''
        mkdir -p $out/waybar $out/dunst $out/btop/themes $out/ghostty/themes $out/qt5ct $out/qt6ct

        # Waybar CSS
        ${
          if cfg.monet.enable && wallpaper != null then
            ''
              ${pkgs.matugen}/bin/matugen image \
                --json hex \
                --mode ${polarity} \
                --type ${cfg.monet.scheme} \
                --source-color-index ${toString cfg.monet.sourceColorIndex} \
                --fallback-color ${lib.escapeShellArg cfg.monet.fallbackColor} \
                '${wallpaper}' > colors.json

              jq -r '
                def c($name): .colors[$name]["${polarity}"].color;
                [
                  "@define-color m3_surface " + c("surface") + ";",
                  "@define-color m3_surface_container " + c("surface_container") + ";",
                  "@define-color m3_surface_container_high " + c("surface_container_high") + ";",
                  "@define-color m3_on_surface " + c("on_surface") + ";",
                  "@define-color m3_on_surface_variant " + c("on_surface_variant") + ";",
                  "@define-color m3_outline " + c("outline") + ";",
                  "@define-color m3_primary " + c("primary") + ";",
                  "@define-color m3_on_primary " + c("on_primary") + ";",
                  "@define-color m3_primary_container " + c("primary_container") + ";",
                  "@define-color m3_on_primary_container " + c("on_primary_container") + ";",
                  "@define-color m3_secondary_container " + c("secondary_container") + ";",
                  "@define-color m3_on_secondary_container " + c("on_secondary_container") + ";",
                  "@define-color m3_tertiary_container " + c("error_container") + ";",
                  "@define-color m3_on_tertiary_container " + c("on_error_container") + ";",
                  "@define-color m3_warning_container " + c("primary_container") + ";",
                  "@define-color m3_on_warning_container " + c("on_primary_container") + ";",
                  ""
                ] | .[]
              ' colors.json > "$out/waybar/style.css"

              cat ${m3WaybarBodyCssPath} >> "$out/waybar/style.css"

              ${lib.optionalString dunstEnabled ''
                cat > "$out/dunst/dunstrc" << 'DUNSTEOF'
                ${dunstMonetTemplate}
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
              ''}

              ${lib.optionalString btopEnabled ''
                jq -r '
                  def c($name): .colors[$name]["${polarity}"].color;
                  [
                    "# Generated by matugen",
                    "theme[main_bg]=\"" + c("surface") + "\"",
                    "theme[main_fg]=\"" + c("on_surface") + "\"",
                    "theme[title]=\"" + c("primary") + "\"",
                    "theme[hi_fg]=\"" + c("primary") + "\"",
                    "theme[selected_bg]=\"" + c("primary_container") + "\"",
                    "theme[selected_fg]=\"" + c("on_primary_container") + "\"",
                    "theme[inactive_fg]=\"" + c("on_surface_variant") + "\"",
                    "theme[graph_text]=\"" + c("on_surface") + "\"",
                    "theme[meter_bg]=\"" + c("surface_container_high") + "\"",
                    "theme[proc_misc]=\"" + c("secondary") + "\"",
                    "theme[cpu_box]=\"" + c("outline") + "\"",
                    "theme[mem_box]=\"" + c("outline") + "\"",
                    "theme[net_box]=\"" + c("outline") + "\"",
                    "theme[proc_box]=\"" + c("outline") + "\"",
                    "theme[div_line]=\"" + c("outline_variant") + "\"",
                    "theme[temp_start]=\"" + c("primary") + "\"",
                    "theme[temp_mid]=\"" + c("secondary") + "\"",
                    "theme[temp_end]=\"" + c("error") + "\"",
                    "theme[cpu_start]=\"" + c("primary") + "\"",
                    "theme[cpu_mid]=\"" + c("secondary") + "\"",
                    "theme[cpu_end]=\"" + c("error") + "\"",
                    "theme[free_start]=\"" + c("tertiary") + "\"",
                    "theme[free_mid]=\"" + c("secondary") + "\"",
                    "theme[free_end]=\"" + c("primary") + "\"",
                    "theme[cached_start]=\"" + c("secondary") + "\"",
                    "theme[cached_mid]=\"" + c("primary") + "\"",
                    "theme[cached_end]=\"" + c("tertiary") + "\"",
                    "theme[available_start]=\"" + c("tertiary") + "\"",
                    "theme[available_mid]=\"" + c("primary") + "\"",
                    "theme[available_end]=\"" + c("secondary") + "\"",
                    "theme[used_start]=\"" + c("primary") + "\"",
                    "theme[used_mid]=\"" + c("secondary") + "\"",
                    "theme[used_end]=\"" + c("error") + "\"",
                    "theme[download_start]=\"" + c("tertiary") + "\"",
                    "theme[download_mid]=\"" + c("secondary") + "\"",
                    "theme[download_end]=\"" + c("primary") + "\"",
                    "theme[upload_start]=\"" + c("primary") + "\"",
                    "theme[upload_mid]=\"" + c("secondary") + "\"",
                    "theme[upload_end]=\"" + c("tertiary") + "\"",
                    "theme[process_start]=\"" + c("primary") + "\"",
                    "theme[process_mid]=\"" + c("secondary") + "\"",
                    "theme[process_end]=\"" + c("tertiary") + "\""
                  ] | .[]
                ' colors.json > "$out/btop/themes/monet.theme"
              ''}

              ${lib.optionalString ghosttyEnabled ''
                jq -r '
                  def c($name): .colors[$name]["${polarity}"].color;
                  [
                    "background = " + c("surface"),
                    "foreground = " + c("on_surface"),
                    "cursor-color = " + c("primary"),
                    "cursor-text = " + c("on_primary"),
                    "selection-background = " + c("primary_container"),
                    "selection-foreground = " + c("on_primary_container"),
                    "palette = 0=" + c("surface_container"),
                    "palette = 1=" + c("error"),
                    "palette = 2=" + c("tertiary"),
                    "palette = 3=" + c("primary"),
                    "palette = 4=" + c("secondary"),
                    "palette = 5=" + c("primary"),
                    "palette = 6=" + c("tertiary"),
                    "palette = 7=" + c("on_surface"),
                    "palette = 8=" + c("outline"),
                    "palette = 9=" + c("error"),
                    "palette = 10=" + c("tertiary"),
                    "palette = 11=" + c("primary"),
                    "palette = 12=" + c("secondary"),
                    "palette = 13=" + c("primary"),
                    "palette = 14=" + c("tertiary"),
                    "palette = 15=" + c("inverse_surface")
                  ] | .[]
                ' colors.json > "$out/ghostty/themes/monet"
              ''}
            ''
          else
            ''
              cat > "$out/waybar/style.css" << 'WAYBAREOF'
              ${waybarCss}
              WAYBAREOF
            ''
        }

        # Qt5ct 配置文件
        cat > "$out/qt5ct/qt5ct.conf" << 'QT5EOF'
        [Appearance]
        style=${qt5ctStyle}
        custom_palette=false
        QT5EOF

        # Qt6ct 配置文件
        cat > "$out/qt6ct/qt6ct.conf" << 'QT6EOF'
        [Appearance]
        style=${qt5ctStyle}
        custom_palette=false
        QT6EOF

        # 主题元数据 JSON — 供外部脚本查询当前状态
        cat > "$out/theme.json" << JSONEOF
        {
          "polarity": "${polarity}",
          "qt5ct_style": "${qt5ctStyle}"
        }
        JSONEOF
      '';

  # ── Darkman hook 脚本：翻转 current 链接并重载应用 ──
  mkHookScript = pkgs.writeShellScript "darkman-switch-theme-hook" ''
    set -euo pipefail

    target="''${1:-}"

    case "$target" in
      dark)
        GTK_THEME=${shellArg cfg.dark.gtkTheme}
        COLOR_SCHEME="prefer-dark"
        CURSOR_THEME=${shellArg cfg.dark.cursorTheme}
        CURSOR_SIZE=${toString cfg.dark.cursorSize}
        WALLPAPER=${wallpaperArg cfg.dark.wallpaper}
        NOTIFY_MSG="夜间模式已激活"
        ;;
      light)
        GTK_THEME=${shellArg cfg.light.gtkTheme}
        COLOR_SCHEME="prefer-light"
        CURSOR_THEME=${shellArg cfg.light.cursorTheme}
        CURSOR_SIZE=${toString cfg.light.cursorSize}
        WALLPAPER=${wallpaperArg cfg.light.wallpaper}
        NOTIFY_MSG="日间模式已激活"
        ;;
      *)
        echo "ERROR: expected darkman mode argument: dark or light" >&2
        exit 2
        ;;
    esac

    THEME_TARGET="${themeBase}/$target"

    if [ ! -d "$THEME_TARGET" ]; then
      echo "ERROR: theme directory not found: $THEME_TARGET" >&2
      exit 1
    fi

    # ── 翻转 current 软链接 (原子操作) ──
    ln -sfn "$target" "${currentSymlink}"

    # ── GTK 主题 (gsettings 即时生效) ──
    if command -v gsettings &>/dev/null; then
      gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" || true
      gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME" || true
      gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" || true
      gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE" || true
    fi

    # ── Waybar — 发送 USR2 信号触发重载 ──
    ${pkgs.procps}/bin/pkill -SIGUSR2 waybar || true

    # ── Dunst — 重新读取 current symlink 指向的 dunstrc ──
    if command -v dunstctl &>/dev/null; then
      ${pkgs.dunst}/bin/dunstctl reload || true
    else
      ${pkgs.procps}/bin/pkill -HUP dunst || true
    fi

    # ── Btop — 下次打开时读取 current symlink 指向的 Monet theme ──

    # ── Wallpaper — 切换壁纸 ──
    if [ -n "$WALLPAPER" ] && command -v awww &>/dev/null; then
      ${pkgs.awww}/bin/awww img "$WALLPAPER" || true
    fi

    # ── 通知 ──
    if command -v notify-send &>/dev/null; then
      ${pkgs.libnotify}/bin/notify-send "$NOTIFY_MSG" || true
    fi

    echo "[darkman] switched to $target mode"
  '';

in
{
  # ═══════════════════════════════════════════════════
  # Options
  # ═══════════════════════════════════════════════════
  options.home-modules.desktop.darkman = {
    enable = lib.mkEnableOption "darkman-based automatic day/night theme switching";

    # ── 地理坐标 ─────────────────────────────────────
    latitude = lib.mkOption {
      type = lib.types.str;
      default = "31.23"; # Shanghai
      description = "Latitude for sunrise/sunset calculation";
    };

    longitude = lib.mkOption {
      type = lib.types.str;
      default = "121.47"; # Shanghai
      description = "Longitude for sunrise/sunset calculation";
    };

    useGeoclue = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use geoclue2 for automatic location detection instead of manual lat/lng";
    };

    # ── 日间主题配置 ────────────────────────────────
    light = {
      waybarCss = lib.mkOption {
        type = lib.types.lines;
        default = m3LightWaybarCss;
        description = "Waybar CSS for light mode";
      };

      qt5ctStyle = lib.mkOption {
        type = lib.types.str;
        default = "Fusion";
        description = "Qt5ct style name for light mode";
      };

      gtkTheme = lib.mkOption {
        type = lib.types.str;
        default = "Adwaita";
        description = "GTK theme name for light mode";
      };

      wallpaper = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Wallpaper image for light mode";
      };

      cursorTheme = lib.mkOption {
        type = lib.types.str;
        default = "catppuccin-mocha-light-cursors";
        description = "Cursor theme name for light mode";
      };

      cursorSize = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "Cursor size for light mode";
      };
    };

    # ── 夜间主题配置 ────────────────────────────────
    dark = {
      waybarCss = lib.mkOption {
        type = lib.types.lines;
        default = m3DarkWaybarCss;
        description = "Waybar CSS for dark mode";
      };

      qt5ctStyle = lib.mkOption {
        type = lib.types.str;
        default = "Fusion";
        description = "Qt5ct style name for dark mode";
      };

      gtkTheme = lib.mkOption {
        type = lib.types.str;
        default = "Adwaita-dark";
        description = "GTK theme name for dark mode";
      };

      wallpaper = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Wallpaper image for dark mode";
      };

      cursorTheme = lib.mkOption {
        type = lib.types.str;
        default = "catppuccin-mocha-dark-cursors";
        description = "Cursor theme name for dark mode";
      };

      cursorSize = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "Cursor size for dark mode";
      };
    };

    monet = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Generate Material You / Monet colors from the configured wallpaper";
      };

      scheme = lib.mkOption {
        type = lib.types.enum [
          "scheme-content"
          "scheme-expressive"
          "scheme-fidelity"
          "scheme-fruit-salad"
          "scheme-monochrome"
          "scheme-neutral"
          "scheme-rainbow"
          "scheme-tonal-spot"
          "scheme-vibrant"
        ];
        default = "scheme-tonal-spot";
        description = "Matugen dynamic color scheme variant. scheme-tonal-spot matches Android Monet defaults most closely.";
      };

      sourceColorIndex = lib.mkOption {
        type = lib.types.int;
        default = 0;
        description = "Matugen source color index selected from the wallpaper palette";
      };

      fallbackColor = lib.mkOption {
        type = lib.types.str;
        default = "#7b7562";
        description = "Fallback source color used by matugen when wallpaper extraction cannot produce a color";
      };
    };
  };

  # ═══════════════════════════════════════════════════
  # Config
  # ═══════════════════════════════════════════════════
  config = lib.mkIf cfg.enable {
    # ── 避免与 stylix GTK/Qt targets 冲突 ────────────
    #    (如果 stylix 模块也设置了 target，darkman 会覆盖)
    stylix.targets.gtk.enable = lib.mkForce false;
    stylix.targets.kde.enable = lib.mkForce false;

    # ── 确保必要工具已安装 ──────────────────────────
    home.packages = [
      pkgs.darkman
      pkgs.libnotify
    ];

    # ── 构建 light + dark 主题 derivation ────────────
    home.file = {
      # 日间主题文件
      ".local/share/themes/light".source = mkThemeDerivation {
        polarity = "light";
        waybarCss = cfg.light.waybarCss;
        wallpaper = cfg.light.wallpaper;
        qt5ctStyle = cfg.light.qt5ctStyle;
      };

      # 夜间主题文件
      ".local/share/themes/dark".source = mkThemeDerivation {
        polarity = "dark";
        waybarCss = cfg.dark.waybarCss;
        wallpaper = cfg.dark.wallpaper;
        qt5ctStyle = cfg.dark.qt5ctStyle;
      };
    };

    # programs.waybar.style 会先生成静态文件；后续 activation 会替换为 current symlink。
    xdg.configFile."waybar/style.css".force = lib.mkForce true;
    xdg.configFile."dunst/dunstrc".force = lib.mkIf dunstEnabled (lib.mkForce true);

    # ── 初始化 current 软链接 (默认为 light) ────────
    home.activation.initDarkmanTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # 确保 current 软链接存在
      if [ ! -L "${currentSymlink}" ]; then
        $DRY_RUN_CMD ln -sfn light "${currentSymlink}"
      fi

      # Qt5ct — 让 qt5ct 从 current symlink 读取
      $DRY_RUN_CMD rm -rf ${homeDir}/.config/qt5ct
      $DRY_RUN_CMD ln -sfn ${currentSymlink}/qt5ct ${homeDir}/.config/qt5ct

      # Qt6ct
      $DRY_RUN_CMD rm -rf ${homeDir}/.config/qt6ct
      $DRY_RUN_CMD ln -sfn ${currentSymlink}/qt6ct ${homeDir}/.config/qt6ct
    '';

    # ── 清理旧的错误 hook 路径 ────────────────────────
    home.activation.cleanupDarkmanLegacyHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # darkman 2.x 会把 ~/.local/share/darkman 下的可执行条目当作现代 hook。
      # 旧配置误把 legacy 目录放在 darkman/ 内，导致 darkman 试图执行目录本身。
      $DRY_RUN_CMD rm -rf ${homeDir}/.local/share/darkman/dark-mode.d
      $DRY_RUN_CMD rm -rf ${homeDir}/.local/share/darkman/light-mode.d
    '';

    # ── Waybar CSS symlink ───────────────────────────
    #    home-manager 的 programs.waybar.style 会生成 style.css,
    #    我们在 activation 中覆盖为指向 theme/current 的软链接
    home.activation.linkWaybarTheme =
      lib.hm.dag.entryAfter [ "initDarkmanTheme" "cleanupDarkmanLegacyHooks" ]
        ''
          WAYBAR_STYLE="${homeDir}/.config/waybar/style.css"
          THEME_STYLE="${currentSymlink}/waybar/style.css"

          if [ -d "$(dirname "$WAYBAR_STYLE")" ] && [ -f "$THEME_STYLE" ]; then
            $DRY_RUN_CMD rm -f "$WAYBAR_STYLE"
            $DRY_RUN_CMD ln -sfn "$THEME_STYLE" "$WAYBAR_STYLE"
            # 如果 waybar 已在运行，触发重载
            ${pkgs.procps}/bin/pkill -SIGUSR2 waybar 2>/dev/null || true
          fi
        '';

    # ── Dunst config symlink ─────────────────────────
    home.activation.linkDunstTheme =
      lib.hm.dag.entryAfter [ "initDarkmanTheme" "cleanupDarkmanLegacyHooks" ]
        ''
          DUNST_CONFIG="${homeDir}/.config/dunst/dunstrc"
          THEME_DUNST="${currentSymlink}/dunst/dunstrc"

          if [ -d "$(dirname "$DUNST_CONFIG")" ] && [ -f "$THEME_DUNST" ]; then
            $DRY_RUN_CMD rm -f "$DUNST_CONFIG"
            $DRY_RUN_CMD ln -sfn "$THEME_DUNST" "$DUNST_CONFIG"
            ${pkgs.dunst}/bin/dunstctl reload 2>/dev/null || ${pkgs.procps}/bin/pkill -HUP dunst 2>/dev/null || true
          fi
        '';

    # ── Btop theme symlink ───────────────────────────
    home.activation.linkBtopTheme =
      lib.hm.dag.entryAfter [ "initDarkmanTheme" "cleanupDarkmanLegacyHooks" ]
        ''
          BTOP_THEME="${homeDir}/.config/btop/themes/monet.theme"
          THEME_BTOP="${currentSymlink}/btop/themes/monet.theme"

          if [ -f "$THEME_BTOP" ]; then
            $DRY_RUN_CMD mkdir -p "$(dirname "$BTOP_THEME")"
            $DRY_RUN_CMD rm -f "$BTOP_THEME"
            $DRY_RUN_CMD ln -sfn "$THEME_BTOP" "$BTOP_THEME"
          fi
        '';

    # ── Ghostty theme symlink ────────────────────────
    home.activation.linkGhosttyTheme =
      lib.hm.dag.entryAfter [ "initDarkmanTheme" "cleanupDarkmanLegacyHooks" ]
        ''
          GHOSTTY_THEME="${homeDir}/.config/ghostty/themes/monet"
          THEME_GHOSTTY="${currentSymlink}/ghostty/themes/monet"

          if [ -f "$THEME_GHOSTTY" ]; then
            $DRY_RUN_CMD mkdir -p "$(dirname "$GHOSTTY_THEME")"
            $DRY_RUN_CMD rm -f "$GHOSTTY_THEME"
            $DRY_RUN_CMD ln -sfn "$THEME_GHOSTTY" "$GHOSTTY_THEME"
          fi
        '';

    # ── Darkman systemd 用户服务 ─────────────────────
    systemd.user.services.darkman = {
      Unit = {
        Description = "Darkman — automatic day/night mode switcher";
        Documentation = "https://darkman.whynothugo.nl/";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.darkman}/bin/darkman run";
        Restart = "on-failure";
        RestartSec = 10;
        Environment = "PATH=${
          lib.makeBinPath [
            pkgs.coreutils
            pkgs.procps
            pkgs.awww
          ]
        }";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # ── Darkman 配置文件 ─────────────────────────────
    xdg.configFile."darkman/config.yaml".text =
      let
        locationConfig =
          if cfg.useGeoclue then
            "use-geoclue: true"
          else
            ''
              lat: ${cfg.latitude}
              lng: ${cfg.longitude}
            '';
      in
      ''
        ${locationConfig}
      '';

    # ── Darkman hook 脚本 ────────────────────────────
    xdg.dataFile = {
      "darkman/switch-theme.sh" = {
        source = mkHookScript;
        executable = true;
      };
    };
  };
}
