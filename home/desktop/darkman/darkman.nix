{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-modules.desktop.darkman;
  homeDir = config.home.homeDirectory;

  # ── 主题文件基础路径 ────────────────────────────
  themeBase = "${homeDir}/.local/share/themes";
  currentSymlink = "${themeBase}/current";

  # ── 构建一个 polarity 变体的所有主题文件 ────────
  mkThemeDerivation =
    {
      polarity,
      waybarCss,
      qt5ctStyle,
    }:
    pkgs.runCommand "darkman-theme-${polarity}"
      {
        nativeBuildInputs = [ pkgs.jq ];
      }
      ''
        mkdir -p $out/waybar $out/qt5ct

        # Waybar CSS
        cat > "$out/waybar/style.css" << 'WAYBAREOF'
        ${waybarCss}
        WAYBAREOF

        # Qt5ct 配置文件
        cat > "$out/qt5ct/qt5ct.conf" << 'QT5EOF'
        [Appearance]
        style=${qt5ctStyle}
        custom_palette=false
        QT5EOF

        # 主题元数据 JSON — 供外部脚本查询当前状态
        cat > "$out/theme.json" << JSONEOF
        {
          "polarity": "${polarity}",
          "qt5ct_style": "${qt5ctStyle}"
        }
        JSONEOF
      '';

  # ── Darkman hook 脚本：翻转 current 链接并重载应用 ──
  mkHookScript =
    target:
    let
      theme = if target == "dark" then cfg.dark else cfg.light;
      wallpaper = theme.wallpaper;
      notifyMsg = if target == "dark" then "夜间模式已激活" else "日间模式已激活";
    in
    pkgs.writeShellScript "darkman-${target}-hook" ''
      set -euo pipefail

      THEME_TARGET="${themeBase}/${target}"

      if [ ! -d "$THEME_TARGET" ]; then
        echo "ERROR: theme directory not found: $THEME_TARGET" >&2
        exit 1
      fi

      # ── 翻转 current 软链接 (原子操作) ──
      ln -sfn "${target}" "${currentSymlink}"

      # ── GTK 主题 (gsettings 即时生效) ──
      if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "${theme.gtkTheme}" || true
        COLOR_SCHEME="${if target == "dark" then "prefer-dark" else "prefer-light"}"
        gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME" || true
        gsettings set org.gnome.desktop.interface cursor-theme "${theme.cursorTheme}" || true
        gsettings set org.gnome.desktop.interface cursor-size ${toString theme.cursorSize} || true
      fi

      # ── Waybar — 发送 USR2 信号触发重载 ──
      ${pkgs.procps}/bin/pkill -SIGUSR2 waybar || true

      # ── Wallpaper — 切换壁纸 ──
      ${
        if wallpaper != null then
          ''
            if command -v awww &>/dev/null; then
              ${pkgs.awww}/bin/awww set "${wallpaper}" || true
            fi
          ''
        else
          ''
            :
          ''
      }

      # ── 通知 ──
      if command -v notify-send &>/dev/null; then
        ${pkgs.libnotify}/bin/notify-send "${notifyMsg}" || true
      fi

      echo "[darkman] switched to ${target} mode"
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
        default = ''
          window#waybar {
              background-color: transparent;
              margin-bottom: 2pt;
          }
          tooltip label {
              margin: -5px -3px;
          }
          #clock {
              margin-left: 2pt;
              margin-right: 2pt;
              border: 2px solid @theme_fg_color;
              border-radius: 8px;
              padding: 0 12px;
              transition: none;
          }
          #workspaces {
              margin-left: 2pt;
              border-left: 2px solid @theme_fg_color;
              border-bottom: 2px solid @theme_fg_color;
              border-top: 2px solid @theme_fg_color;
              border-radius: 8px 0 0 8px;
              padding: 0 6px;
              transition: none;
          }
          #window {
              border-right: 2px solid @theme_fg_color;
              border-top: 2px solid @theme_fg_color;
              border-bottom: 2px solid @theme_fg_color;
              border-radius: 0 8px 8px 0;
              padding: 0 12px;
              transition: none;
          }
          window#waybar.empty #window {
              background-color: transparent;
              border: none;
          }
          window#waybar.empty #workspaces {
              border-right: 2px solid @theme_fg_color;
              border-radius: 8px;
          }
          #tray {
              border-left: 2px solid @theme_fg_color;
              border-bottom: 2px solid @theme_fg_color;
              border-top: 2px solid @theme_fg_color;
              border-radius: 8px 0 0 8px;
              padding: 0 12px;
          }
          #network,
          #cpu,
          #memory {
              border-top: 2px solid @theme_fg_color;
              border-bottom: 2px solid @theme_fg_color;
              padding: 0 12px;
              transition: none;
          }
          #battery {
              margin-right: 2pt;
              border-right: 2px solid @theme_fg_color;
              border-top: 2px solid @theme_fg_color;
              border-bottom: 2px solid @theme_fg_color;
              border-radius: 0 8px 8px 0;
              padding: 0 12px;
              transition: none;
          }
          #workspaces button {
              padding: 0 2px;
          }
        '';
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
        default = ''
          window#waybar {
              background-color: transparent;
              margin-bottom: 2pt;
          }
          tooltip label {
              margin: -5px -3px;
          }
          #clock {
              margin-left: 2pt;
              margin-right: 2pt;
              border: 2px solid @theme_fg_color;
              border-radius: 8px;
              padding: 0 12px;
              transition: none;
          }
          #workspaces {
              margin-left: 2pt;
              border-left: 2px solid @theme_fg_color;
              border-bottom: 2px solid @theme_fg_color;
              border-top: 2px solid @theme_fg_color;
              border-radius: 8px 0 0 8px;
              padding: 0 6px;
              transition: none;
          }
          #window {
              border-right: 2px solid @theme_fg_color;
              border-top: 2px solid @theme_fg_color;
              border-bottom: 2px solid @theme_fg_color;
              border-radius: 0 8px 8px 0;
              padding: 0 12px;
              transition: none;
          }
          window#waybar.empty #window {
              background-color: transparent;
              border: none;
          }
          window#waybar.empty #workspaces {
              border-right: 2px solid @theme_fg_color;
              border-radius: 8px;
          }
          #tray {
              border-left: 2px solid @theme_fg_color;
              border-bottom: 2px solid @theme_fg_color;
              border-top: 2px solid @theme_fg_color;
              border-radius: 8px 0 0 8px;
              padding: 0 12px;
          }
          #network,
          #cpu,
          #memory {
              border-top: 2px solid @theme_fg_color;
              border-bottom: 2px solid @theme_fg_color;
              padding: 0 12px;
              transition: none;
          }
          #battery {
              margin-right: 2pt;
              border-right: 2px solid @theme_fg_color;
              border-top: 2px solid @theme_fg_color;
              border-bottom: 2px solid @theme_fg_color;
              border-radius: 0 8px 8px 0;
              padding: 0 12px;
              transition: none;
          }
          #workspaces button {
              padding: 0 2px;
          }
        '';
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
        qt5ctStyle = cfg.light.qt5ctStyle;
      };

      # 夜间主题文件
      ".local/share/themes/dark".source = mkThemeDerivation {
        polarity = "dark";
        waybarCss = cfg.dark.waybarCss;
        qt5ctStyle = cfg.dark.qt5ctStyle;
      };
    };

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

    # ── Waybar CSS symlink ───────────────────────────
    #    home-manager 的 programs.waybar.style 会生成 style.css,
    #    我们在 activation 中覆盖为指向 theme/current 的软链接
    home.activation.linkWaybarTheme = lib.hm.dag.entryAfter [ "initDarkmanTheme" ] ''
      WAYBAR_STYLE="${homeDir}/.config/waybar/style.css"
      THEME_STYLE="${currentSymlink}/waybar/style.css"

      if [ -d "$(dirname "$WAYBAR_STYLE")" ] && [ -f "$THEME_STYLE" ]; then
        $DRY_RUN_CMD rm -f "$WAYBAR_STYLE"
        $DRY_RUN_CMD ln -sfn "$THEME_STYLE" "$WAYBAR_STYLE"
        # 如果 waybar 已在运行，触发重载
        ${pkgs.procps}/bin/pkill -SIGUSR2 waybar 2>/dev/null || true
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
      "darkman/dark-mode.d/switch-theme.sh" = {
        source = mkHookScript "dark";
        executable = true;
      };
      "darkman/light-mode.d/switch-theme.sh" = {
        source = mkHookScript "light";
        executable = true;
      };
    };
  };
}
