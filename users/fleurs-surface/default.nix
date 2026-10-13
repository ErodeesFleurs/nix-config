# Fleurs 用户配置（Spectre Surface；共享配置在 ../common.nix）
{
  pkgs,
  config,
  ...
}:
let
  toggleKeyboard = pkgs.writeShellScript "surface-keyboard-toggle" ''
    if ${pkgs.systemd}/bin/systemctl --user is-active --quiet surface-keyboard.service; then
      exec ${pkgs.systemd}/bin/systemctl --user stop surface-keyboard.service
    else
      exec ${pkgs.systemd}/bin/systemctl --user start surface-keyboard.service
    fi
  '';
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

  # Surface 触摸板自然滚动（合并进共享 niri 配置）
  programs.niri.settings.input.touchpad.natural-scroll = true;

  # wvkbd 不使用 --auto：自动显示会争用 Fcitx5 的 input-method-v2 seat。
  # 按需启动的 virtual-keyboard 从 Quickshell 触控入口或实体键盘快捷键切换。
  systemd.user.services.surface-keyboard = {
    Unit = {
      Description = "Surface on-screen keyboard";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service.ExecStart = "${pkgs.wvkbd}/bin/wvkbd-mobintl";
  };

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
