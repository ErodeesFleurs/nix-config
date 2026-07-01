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
  monetLib = import ../../../lib/monet.nix { inherit lib pkgs; };

  # ── 主题文件基础路径 ────────────────────────────
  themeBase = "${homeDir}/.local/share/themes";
  currentSymlink = "${themeBase}/current";

  m3LightWaybarCss = builtins.readFile ../../../assets/waybar/m3-expressive-light.css;
  m3DarkWaybarCss = builtins.readFile ../../../assets/waybar/m3-expressive-dark.css;
  m3WaybarBodyCssPath = ../../../assets/waybar/m3-expressive-body.css;
  monetTheme = import ../theme/monet {
    inherit config lib pkgs;
    waybarBodyCssPath = m3WaybarBodyCssPath;
  };

  # ── 构建一个 polarity 变体的所有主题文件 ────────
  mkThemeDerivation =
    {
      polarity,
      waybarCss,
      wallpaper,
      qt5ctStyle,
    }:
    pkgs.runCommand "darkman-theme-${polarity}"
      (
        {
          nativeBuildInputs = [ pkgs.jq ];
        }
        // lib.optionalAttrs (cfg.monet.enable && wallpaper != null) {
          wallpaperPath = wallpaper;
        }
      )
      ''
        ${monetTheme.createOutputDirs}

        ${
          if cfg.monet.enable && wallpaper != null then
            ''
              ${monetLib.mkMatugenImageCommand {
                mode = polarity;
                inherit (cfg.monet)
                  scheme
                  sourceColorIndex
                  fallbackColor
                  ;
              }}

              ${monetTheme.generate { inherit polarity; }}
            ''
          else
            ''
              cat > "$out/waybar/style.css" << 'WAYBAREOF'
              ${waybarCss}
              WAYBAREOF

              mkdir -p "$out/qt5ct" "$out/qt6ct"

              cat > "$out/qt5ct/qt5ct.conf" << 'QT5EOF'
              [Appearance]
              style=${qt5ctStyle}
              custom_palette=false
              QT5EOF

              cat > "$out/qt6ct/qt6ct.conf" << 'QT6EOF'
              [Appearance]
              style=${qt5ctStyle}
              custom_palette=false
              QT6EOF
            ''
        }

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

    # ── Ghostty — 显式切换当前主题文件 ──
    GHOSTTY_THEME="${homeDir}/.config/ghostty/themes/monet-current"
    GHOSTTY_THEME_SOURCE="${currentSymlink}/ghostty/themes/monet-$target"
    if [ -f "$GHOSTTY_THEME_SOURCE" ]; then
      ln -sfn "$GHOSTTY_THEME_SOURCE" "$GHOSTTY_THEME"
    fi

    # ── Ghostty — 发送 USR2 信号触发配置和 light/dark 主题重载 ──
    ${pkgs.procps}/bin/pkill -SIGUSR2 ghostty || true

    # ── Dunst — 重新读取 current symlink 指向的 dunstrc ──
    DUNST_CONFIG="${currentSymlink}/dunst/dunstrc"
    if command -v dunstctl &>/dev/null; then
      ${pkgs.dunst}/bin/dunstctl reload "$DUNST_CONFIG" 2>/dev/null \
        || ${pkgs.procps}/bin/pkill -HUP dunst 2>/dev/null \
        || true
    else
      ${pkgs.procps}/bin/pkill -HUP dunst 2>/dev/null || true
    fi

    # ── Btop — 下次打开时读取 current symlink 指向的 Monet theme ──

    # ── Fcitx5 — 重新读取 current symlink 指向的候选框主题 ──
    if command -v fcitx5-remote &>/dev/null; then
      fcitx5-remote -r >/dev/null 2>&1 || true
    fi

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
        default = "Adwaita";
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
        default = "Adwaita";
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

      scheme = monetLib.mkSchemeOption {
        default = "scheme-tonal-spot";
        description = "Matugen dynamic color scheme variant. scheme-tonal-spot matches Android Monet defaults most closely.";
      };

      sourceColorIndex = monetLib.mkSourceColorIndexOption {
        default = 0;
        description = "Matugen source color index selected from the wallpaper palette";
      };

      fallbackColor = monetLib.mkFallbackColorOption {
        default = "#7b7562";
        description = "Fallback source color used by matugen when wallpaper extraction cannot produce a color";
      };
    };
  };

  # ═══════════════════════════════════════════════════
  # Config
  # ═══════════════════════════════════════════════════
  config = lib.mkIf cfg.enable {
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

    xdg.configFile = lib.optionalAttrs cfg.monet.enable monetTheme.xdgConfig // {
      # ── Darkman 配置文件 ─────────────────────────────
      "darkman/config.yaml".text =
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
    };

    home.activation = lib.optionalAttrs cfg.monet.enable monetTheme.activation // {
      # ── 初始化 current 软链接 (默认为 light) ────────
      initThemeLinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
      cleanupDarkmanLegacyHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # darkman 2.x 会把 ~/.local/share/darkman 下的可执行条目当作现代 hook。
        # 旧配置误把 legacy 目录放在 darkman/ 内，导致 darkman 试图执行目录本身。
        $DRY_RUN_CMD rm -rf ${homeDir}/.local/share/darkman/dark-mode.d
        $DRY_RUN_CMD rm -rf ${homeDir}/.local/share/darkman/light-mode.d
      '';

    };

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

    # ── Darkman hook 脚本 ────────────────────────────
    xdg.dataFile = {
      "darkman/switch-theme.sh" = {
        source = mkHookScript;
        executable = true;
      };
    };
  };
}
