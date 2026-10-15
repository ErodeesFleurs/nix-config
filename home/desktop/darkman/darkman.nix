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

  monetTheme = import ../theme/monet {
    # 与所有应用共享同一套 Material 色板，不让状态栏独立生成主题。
    inherit config lib pkgs;
  };
  themeLib = import ../theme/monet/lib.nix { inherit config lib pkgs; };

  mkHookBlock = title: body: ''
    # ── ${title} ──
    ${body}
  '';

  switchActions = lib.concatStringsSep "\n" [
    (lib.optionalString config.programs.quickshell.enable (
      mkHookBlock "Quickshell — current 翻转后重新读取色板" themeLib.reloadScripts.quickshell
    ))

    (lib.optionalString config.homeModules.desktop.quickshell.keyboard.enable (
      mkHookBlock "屏幕键盘 — 仅刷新已打开的键盘，不在切换主题时弹出" ''
        ${pkgs.systemd}/bin/systemctl --user try-restart ${lib.escapeShellArg config.homeModules.desktop.quickshell.keyboard.unit}
      ''
    ))

    (lib.optionalString config.programs.ghostty.enable (
      mkHookBlock "Ghostty — 发送 USR2 信号触发主题文件重读" ''
        ${pkgs.procps}/bin/pkill -SIGUSR2 ghostty 2>/dev/null || true
      ''
    ))

    (lib.optionalString (config.services.mako.enable && config.services.mako.package != null) (
      mkHookBlock "Mako — 重新读取 current symlink 指向的配置" ''
        ${config.services.mako.package}/bin/makoctl reload 2>/dev/null || true
      ''
    ))

    (mkHookBlock "Fcitx5 — 重新读取 classicui addon，候选框主题属于该 addon" themeLib.reloadScripts.fcitx5)

    (lib.optionalString config.services.awww.enable (
      mkHookBlock "Wallpaper — 切换壁纸" ''
        if [ -n "$WALLPAPER" ]; then
          ${config.services.awww.package}/bin/awww img "$WALLPAPER" 2>/dev/null || true
        fi
      ''
    ))

    (lib.optionalString config.services.mako.enable (
      mkHookBlock "通知" ''
        ${pkgs.libnotify}/bin/notify-send "$NOTIFY_MSG" 2>/dev/null || true
      ''
    ))
  ];

  # ── 单产物构建：一棵产物含 light/ 与 dark/ 两棵子树 ──
  variants = {
    light = {
      inherit (cfg.light)
        wallpaper
        quickshellPalette
        iconTheme
        ;
    };
    dark = {
      inherit (cfg.dark)
        wallpaper
        quickshellPalette
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
          mkdir -p "$out/light/quickshell" "$out/dark/quickshell"
          cat > "$out/light/quickshell/palette.json" << 'PALETTEEOF'
          ${builtins.toJSON (variants.light.quickshellPalette // { mode = "light"; })}
          PALETTEEOF
          cat > "$out/dark/quickshell/palette.json" << 'PALETTEEOF'
          ${builtins.toJSON (variants.dark.quickshellPalette // { mode = "dark"; })}
          PALETTEEOF
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

    # ── 翻转 current 软链接（临时链接 + rename 真原子，无不存在窗口）──
    ${pkgs.coreutils}/bin/ln -sfn "$target" "${currentSymlink}.tmp"
    ${pkgs.coreutils}/bin/mv -T "${currentSymlink}.tmp" "${currentSymlink}"

    # ── GTK 主题：只为这五次调用提供 Nixpkgs 的 schema 路径，不依赖 session 环境 ──
    # 必需设置失败时让 hook 返回失败；下方可选应用重载仍保持 best-effort。
    (
      export GSETTINGS_SCHEMA_DIR=${shellArg (pkgs.glib.getSchemaPath pkgs.gsettings-desktop-schemas)}
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME"
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE"
    )

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
      type = lib.types.float;
      default = 31.23; # Shanghai
      description = "Latitude for sunrise/sunset calculation";
    };

    longitude = lib.mkOption {
      type = lib.types.float;
      default = 121.47; # Shanghai
      description = "Longitude for sunrise/sunset calculation";
    };

    useGeoclue = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use geoclue2 for automatic location detection instead of manual lat/lng";
    };

    # ── 日间主题配置 ────────────────────────────────
    light = {
      quickshellPalette = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          surface = "#fffbfe";
          surfaceContainer = "#f3edf7";
          surfaceContainerHigh = "#ece6f0";
          onSurface = "#1d1b20";
          onSurfaceVariant = "#49454f";
          outline = "#79747e";
          primary = "#005db8";
          onPrimary = "#ffffff";
          primaryContainer = "#d6e3ff";
          onPrimaryContainer = "#001b3f";
          error = "#ba1a1a";
          onError = "#ffffff";
        };
        description = "Static light Material palette for Quickshell when wallpaper-derived Monet is disabled.";
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
      quickshellPalette = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          surface = "#111318";
          surfaceContainer = "#1d2027";
          surfaceContainerHigh = "#29313b";
          onSurface = "#e6e1e5";
          onSurfaceVariant = "#cac4d0";
          outline = "#938f99";
          primary = "#a8c7fa";
          onPrimary = "#00315f";
          primaryContainer = "#1f3b63";
          onPrimaryContainer = "#d6e3ff";
          error = "#ffb4ab";
          onError = "#690005";
        };
        description = "Static dark Material palette for Quickshell when wallpaper-derived Monet is disabled.";
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
    # ── 确保必要工具已安装（darkman 本体由 services.darkman 模块安装）──
    home.packages = [
      pkgs.libnotify
    ];

    # ── 单主题产物（light/ dark 子树） ────────────
    home.file = {
      ".local/share/themes/light".source = "${mkThemes}/light";
      ".local/share/themes/dark".source = "${mkThemes}/dark";
    };

    xdg.configFile = lib.optionalAttrs cfg.monet.enable monetTheme.xdgConfig;

    home.activation = lib.optionalAttrs cfg.monet.enable monetTheme.activation // {
      # ── 初始化 current 软链接 (默认为 light) ────────
      initThemeLinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # 确保 current 软链接存在
        if [ ! -L "${currentSymlink}" ]; then
          $DRY_RUN_CMD ln -sfn light "${currentSymlink}"
        fi

        # Qt6ct 死轨清理：qt6ct 从未生效，Qt 经 Settings portal 跟随昼夜
        $DRY_RUN_CMD rm -f ${homeDir}/.config/qt6ct
      '';

      # ── 清理旧的错误 hook 路径 ────────────────────────
      cleanupDarkmanLegacyHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # darkman 2.x 会把 ~/.local/share/darkman 下的可执行条目当作现代 hook。
        # 旧配置误把 legacy 目录放在 darkman/ 内，导致 darkman 试图执行目录本身。
        $DRY_RUN_CMD rm -rf ${homeDir}/.local/share/darkman/dark-mode.d
        $DRY_RUN_CMD rm -rf ${homeDir}/.local/share/darkman/light-mode.d
      '';

    };

    # ── Darkman 服务（HM 原生：dbus 单元 + config 变更自动重启）─────
    services.darkman = {
      enable = true;
      settings = {
        lat = cfg.latitude;
        lng = cfg.longitude;
        usegeoclue = cfg.useGeoclue;
      };
    };

    # darkman 启动时会立即执行当前模式的 hook；hook 更新也应触发一次重启，
    # 避免 apply 后模式未变化时继续保留旧的 GTK 设置。昼夜切换不重启服务。
    systemd.user.services.darkman.Unit.X-Restart-Triggers = [ "${mkHookScript}" ];

    # ── Darkman hook 脚本 ────────────────────────────
    xdg.dataFile = {
      "darkman/switch-theme.sh" = {
        source = mkHookScript;
        executable = true;
      };
    };
  };
}
