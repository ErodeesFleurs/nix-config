# Fleurs 用户配置（Spectre Surface；共享配置在 ../common.nix）
{
  pkgs,
  config,
  lib,
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
  keyboardStatus = pkgs.writeShellScript "surface-keyboard-status" ''
    if ${pkgs.systemd}/bin/systemctl --user is-active --quiet surface-keyboard.service; then
      echo '{"text":"键盘","tooltip":"关闭屏幕键盘","class":"active"}'
    else
      echo '{"text":"键盘","tooltip":"打开屏幕键盘","class":"inactive"}'
    fi
  '';
in

{
  imports = [ ../common.nix ];

  home.packages = with pkgs; [
    rar
    go-musicfox
  ];

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
  # 按需启动的 virtual-keyboard 可以从 Waybar 触摸入口或实体键盘快捷键切换。
  systemd.user.services.surface-keyboard = {
    Unit = {
      Description = "Surface on-screen keyboard";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service.ExecStart = "${pkgs.wvkbd}/bin/wvkbd-mobintl";
  };

  programs.waybar.settings.main = {
    modules-right = lib.mkBefore [ "custom/surface-keyboard" ];
    "custom/surface-keyboard" = {
      exec = "${keyboardStatus}";
      return-type = "json";
      interval = 2;
      on-click = "${toggleKeyboard}";
    };
  };

  programs.niri.settings.binds."Mod+K" = {
    action.spawn = [ "${toggleKeyboard}" ];
    hotkey-overlay.title = "On-screen Keyboard";
  };
}
