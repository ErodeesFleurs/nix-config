# Fleurs 用户配置（Spectre Surface；共享配置在 ../common.nix）
{
  pkgs,
  config,
  lib,
  ...
}:
let
  # 原生 layer-shell 悬浮面板：保持 virtual-keyboard 输入，不创建抢焦点的普通窗口。
  floatingWvkbd = pkgs.wvkbd.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../../patches/wvkbd/floating-render.patch
      ../../patches/wvkbd/floating-input.patch
    ];
  });
  toggleKeyboard = pkgs.writeShellScript "surface-keyboard-toggle" ''
    if ${pkgs.systemd}/bin/systemctl --user is-active --quiet surface-keyboard.service; then
      exec ${pkgs.systemd}/bin/systemctl --user stop surface-keyboard.service
    else
      exec ${pkgs.systemd}/bin/systemctl --user start surface-keyboard.service
    fi
  '';
  # 直接消费 Quickshell 的 Monet 色板，避免维护另一套明暗主题。
  # 默认键区横屏 280 / 竖屏 320 逻辑像素，外加拖动栏和内边距。
  # 拖动位置只保存在会话 runtime 目录，明暗主题重启后保留，注销后清除。
  # 字体沿用状态栏；圆角与强调色区分功能键，按下时使用 primary/onPrimary。
  surfaceKeyboard = pkgs.writeShellApplication {
    name = "surface-keyboard";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      colors="$(jq -er '
        [.surface, .surfaceContainerHigh, .primaryContainer, .onSurface,
         .onPrimaryContainer, .primary, .onPrimary]
        | map(ltrimstr("#")) | @tsv
      ' ${lib.escapeShellArg "${config.home.homeDirectory}/.local/share/themes/current/quickshell/palette.json"})"
      IFS=$'\t' read -r bg key special text special_text pressed pressed_text <<< "$colors"

      export WVKBD_POSITION_FILE="$XDG_RUNTIME_DIR/surface-keyboard.position"
      exec ${floatingWvkbd}/bin/wvkbd-mobintl \
        --floating -H 320 -L 280 -R 12 \
        --fn ${lib.escapeShellArg "${config.homeModules.theme.fonts.monospace.name} 18"} \
        --bg "$bg" --fg "$key" --fg-sp "$special" \
        --text "$text" --text-sp "$special_text" \
        --press "$pressed" --press-sp "$pressed" \
        --text-press "$pressed_text" --text-press-sp "$pressed_text" \
        --swipe "$special" --swipe-sp "$special" \
        --text-swipe "$special_text" --text-swipe-sp "$special_text"
    '';
  };
in

{
  imports = [ ../common.nix ];

  home.packages = with pkgs; [
    rar
    go-musicfox
  ];

  homeModules.krita.enable = true;

  # 沿用 Surface 已有的 Firefox profile；避免主题配置写入未使用的 XDG profile。
  programs.firefox = {
    configPath = ".mozilla/firefox";
    profiles.${config.homeModules.firefox.profile-name}.path = "ftj1tpra.default";
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };

  programs.niri.settings = {
    # 内置触屏/触笔固定映射到内屏；外接显示器不改变落点。
    input = {
      touchpad.natural-scroll = true;
      touch.map-to-output = "eDP-1";
      tablet.map-to-output = "eDP-1";
    };
    # 保留支持 CSD 的应用标题栏，手指也能关闭、最大化和拖动窗口。
    prefer-no-csd = false;
    binds."Mod+O" = {
      action.toggle-overview = [ ];
      hotkey-overlay.title = "Window Overview";
    };
  };

  # wvkbd 不使用 --auto：自动显示会争用 Fcitx5 的 input-method-v2 seat。
  # 按需启动的 virtual-keyboard 从 Quickshell 触控入口或实体键盘快捷键切换。
  # 启动即悬浮：拖动顶部横条区域，右上角 × 退出；最大宽度 840 逻辑像素。
  # 不预留屏幕空间、不改变窗口大小；若遮挡输入框，可拖开，旋转后自动约束边界。
  systemd.user.services.surface-keyboard = {
    Unit = {
      Description = "Surface floating on-screen keyboard";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service.ExecStart = lib.getExe surfaceKeyboard;
  };

  # 纯触屏：左上总览按钮 / Mod+O；右上控制中心提供切列、列宽及横竖屏。
  # 使用最大列宽而非全屏，保留键盘按钮；旋转仅作用于当前会话，不启用自动旋转。
  homeModules.desktop.quickshell = {
    touch = true;
    keyboard = {
      enable = true;
      toggleCommand = [ "${toggleKeyboard}" ];
    };
  };

  programs.niri.settings.binds."Mod+K" = {
    action.spawn = [ "${toggleKeyboard}" ];
    hotkey-overlay.title = "On-screen Keyboard";
  };
}
