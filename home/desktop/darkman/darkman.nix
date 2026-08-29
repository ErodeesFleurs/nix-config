{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.desktop.darkman;
  homeDir = config.home.homeDirectory;
  shellArg = value: lib.escapeShellArg (toString value);
  wallpaperArg = wallpaper: if wallpaper == null then "''" else shellArg wallpaper;
  monetLib = import ../../../lib/monet.nix { inherit lib; };

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
  themeLib = import ../theme/monet/lib.nix { inherit config lib pkgs; };

  mkHookBlock = title: body: ''
    # ── ${title} ──
    ${body}
  '';

  switchActions = lib.concatStringsSep "\n" [
    (mkHookBlock "Waybar — 发送 USR2 信号触发重载" themeLib.reloadScripts.waybar)

    (mkHookBlock "Ghostty — 发送 USR2 信号触发主题文件重读" ''
      ${pkgs.procps}/bin/pkill -SIGUSR2 ghostty || true
    '')

    (mkHookBlock "Mako — 重新读取 current symlink 指向的配置" ''
      if command -v makoctl &>/dev/null; then
        ${pkgs.mako}/bin/makoctl reload 2>/dev/null || true
      fi
    '')

    (mkHookBlock "Btop — 下次打开时读取 current symlink 指向的 Monet theme" "")

    (mkHookBlock "Fcitx5 — 重新读取 classicui addon，候选框主题属于该 addon" themeLib.reloadScripts.fcitx5)

    (mkHookBlock "Wallpaper — 切换壁纸" ''
      if [ -n "$WALLPAPER" ] && command -v awww &>/dev/null; then
        ${pkgs.awww}/bin/awww img "$WALLPAPER" || true
      fi
    '')

    (mkHookBlock "通知" ''
      if command -v notify-send &>/dev/null; then
        ${pkgs.libnotify}/bin/notify-send "$NOTIFY_MSG" || true
      fi
    '')
  ];

  # ── 单产物构建：一棵产物含 light/ 与 dark/ 两棵子树 ──
  variants = {
    light = {
      inherit (cfg.light)
        wallpaper
        waybarCss
        qt5ctStyle
        iconTheme
        ;
    };
    dark = {
      inherit (cfg.dark)
        wallpaper
        waybarCss
        qt5ctStyle
        iconTheme
        ;
    };
  };

  wallpapers = lib.unique (
    lib.filter (w: w != null) [
      variants.light.wallpaper
      variants.dark.wallpaper
    ]
  );
  sameWallpaper = builtins.length wallpapers == 1;

  matugenCmd = config: wallpaper: ''
    cp ${config} "$out/config.toml"
    ${pkgs.matugen}/bin/matugen image \
      --mode dark \
      --type ${cfg.monet.scheme} \
      --source-color-index ${toString cfg.monet.sourceColorIndex} \
      --fallback-color ${lib.escapeShellArg cfg.monet.fallbackColor} \
      "${wallpaper}" \
      -c "$out/config.toml"
    rm "$out/config.toml"
  '';

  mkThemeJson = polarity: v: ''
    mkdir -p "$out/${polarity}"
    cat > "$out/${polarity}/theme.json" << JSONEOF
    {
      "polarity": "${polarity}",
      "qt5ct_style": "${v.qt5ctStyle}",
      "icon_theme": "${v.iconTheme}"
    }
    JSONEOF
  '';

  mkThemes = pkgs.runCommand "darkman-themes" { } ''
    mkdir -p "$out"

    ${
      if cfg.monet.enable && wallpapers != [ ] then
        if sameWallpaper then
          # 同一壁纸：单次 matugen 运行渲染两棵子树
          matugenCmd monetTheme.configToml (builtins.head wallpapers)
        else
          # 壁纸不同：按子树各跑一次
          matugenCmd (monetTheme.configTomlFor "light") variants.light.wallpaper
          + matugenCmd (monetTheme.configTomlFor "dark") variants.dark.wallpaper
      else
        # 非 monet / 无壁纸：静态样式写入两棵子树
        ''
          mkdir -p "$out/light/waybar" "$out/dark/waybar" "$out/light/qt6ct" "$out/dark/qt6ct"

          cat > "$out/light/waybar/style.css" << 'WAYBAREOF'
          ${variants.light.waybarCss}
          WAYBAREOF

          cat > "$out/dark/waybar/style.css" << 'WAYBAREOF'
          ${variants.dark.waybarCss}
          WAYBAREOF

          cat > "$out/light/qt6ct/qt6ct.conf" << 'QT6EOF'
          [Appearance]
          style=${variants.light.qt5ctStyle}
          icon_theme=${variants.light.iconTheme}
          custom_palette=false
          QT6EOF

          cat > "$out/dark/qt6ct/qt6ct.conf" << 'QT6EOF'
          [Appearance]
          style=${variants.dark.qt5ctStyle}
          icon_theme=${variants.dark.iconTheme}
          custom_palette=false
          QT6EOF
        ''
    }

    # 各应用的自定义后处理（按子树执行，out 变量指向对应子树）
    ( out="$out/light"; ${monetTheme.generate { polarity = "light"; }} )
    ( out="$out/dark"; ${monetTheme.generate { polarity = "dark"; }} )

    # 主题元数据 JSON — 供外部脚本查询当前状态
    ${mkThemeJson "light" variants.light}
    ${mkThemeJson "dark" variants.dark}
  '';

  # ── Darkman hook 脚本：翻转 current 链接并重载应用 ──
  mkHookScript = pkgs.writeShellScript "darkman-switch-theme-hook" ''
    set -euo pipefail

    target="''${1:-}"

    case "$target" in
      dark)
        GTK_THEME=${shellArg cfg.dark.gtkTheme}
        ICON_THEME=${shellArg cfg.dark.iconTheme}
        COLOR_SCHEME="prefer-dark"
        CURSOR_THEME=${shellArg cfg.dark.cursorTheme}
        CURSOR_SIZE=${toString cfg.dark.cursorSize}
        WALLPAPER=${wallpaperArg cfg.dark.wallpaper}
        NOTIFY_MSG="夜间模式已激活"
        ;;
      light)
        GTK_THEME=${shellArg cfg.light.gtkTheme}
        ICON_THEME=${shellArg cfg.light.iconTheme}
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
      gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" || true
      gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME" || true
      gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" || true
      gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE" || true
    fi

    ${switchActions}

    echo "[darkman] switched to $target mode"
  '';

in
{
  # ═══════════════════════════════════════════════════
  # Options
  # ═══════════════════════════════════════════════════
  options.homeModules.desktop.darkman = {
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

      iconTheme = lib.mkOption {
        type = lib.types.str;
        default = config.homeModules.theme.icons.lightName;
        description = "Icon theme name for light mode";
      };

      wallpaper = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Wallpaper image for light mode";
      };

      cursorTheme = lib.mkOption {
        type = lib.types.str;
        # 与 homeModules.theme.cursor 保持单一来源
        default = config.homeModules.theme.cursor.name;
        description = "Cursor theme name for light mode";
      };

      cursorSize = lib.mkOption {
        type = lib.types.int;
        default = config.homeModules.theme.cursor.size;
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

      iconTheme = lib.mkOption {
        type = lib.types.str;
        default = config.homeModules.theme.icons.darkName;
        description = "Icon theme name for dark mode";
      };

      wallpaper = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Wallpaper image for dark mode";
      };

      cursorTheme = lib.mkOption {
        type = lib.types.str;
        # 与 homeModules.theme.cursor 保持单一来源
        default = config.homeModules.theme.cursor.name;
        description = "Cursor theme name for dark mode";
      };

      cursorSize = lib.mkOption {
        type = lib.types.int;
        default = config.homeModules.theme.cursor.size;
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
        default = monetLib.defaults.scheme;
        description = "Matugen dynamic color scheme variant. scheme-tonal-spot matches Android Monet defaults most closely.";
      };

      sourceColorIndex = monetLib.mkSourceColorIndexOption {
        default = monetLib.defaults.sourceColorIndex;
        description = "Matugen source color index selected from the wallpaper palette";
      };

      fallbackColor = monetLib.mkFallbackColorOption {
        default = monetLib.defaults.fallbackColor;
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

    # ── 单主题产物（light/ dark 子树） ────────────
    home.file = {
      ".local/share/themes/light".source = "${mkThemes}/light";
      ".local/share/themes/dark".source = "${mkThemes}/dark";
    };

    xdg.configFile = lib.optionalAttrs cfg.monet.enable monetTheme.xdgConfig // {
      # ── Darkman 配置文件 ─────────────────────────────
      "darkman/config.yaml".text =
        let
          locationConfig = lib.optionalString cfg.useGeoclue "usegeoclue: true\n" + ''
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

        # Qt6ct — 让 qt6ct 从 current symlink 读取
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
