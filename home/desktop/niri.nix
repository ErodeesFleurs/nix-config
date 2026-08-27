{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  niriSettings = {
    spawn-at-startup = [
      {
        argv = [
          "wl-paste"
          "--watch"
          "cliphist"
          "store"
        ];
      }
    ];

    prefer-no-csd = true;

    # 输入设备（原 services.libinput / xserver.xkb 仅作用于 X11，对 niri 无效，迁移至此）
    input = {
      keyboard.xkb.layout = "cn";
      touchpad = {
        tap = true;
        dwt = true;
        # niri-flake 的 natural-scroll 默认 true；显式关闭，各用户文件可覆盖
        natural-scroll = lib.mkDefault false;
      };
    };

    binds = {
      "Mod+T" = {
        action.spawn = [ "ghostty" ];
        hotkey-overlay = {
          title = "Terminal";
        };
      };
      "Mod+R" = {
        action.spawn = [
          "vicinae"
          "toggle"
        ];
        hotkey-overlay = {
          title = "Application Launcher";
        };
      };
      "Mod+C" = {
        action.close-window = [ ];
      };
      "Mod+F" = {
        action.fullscreen-window = [ ];
      };

      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+Shift+1".action.move-window-to-workspace = 1;
      "Mod+Shift+2".action.move-window-to-workspace = 2;
      "Mod+Shift+3".action.move-window-to-workspace = 3;
      "Mod+Shift+4".action.move-window-to-workspace = 4;
      "Mod+Shift+5".action.move-window-to-workspace = 5;
      "Mod+Shift+6".action.move-window-to-workspace = 6;
      "Mod+Shift+7".action.move-window-to-workspace = 7;
      "Mod+Shift+8".action.move-window-to-workspace = 8;
      "Mod+Shift+9".action.move-window-to-workspace = 9;

      "Mod+WheelScrollDown".action.focus-column-right = [ ];
      "Mod+WheelScrollUp".action.focus-column-left = [ ];
      "Mod+Shift+WheelScrollDown".action.move-column-right = [ ];
      "Mod+Shift+WheelScrollUp".action.move-column-left = [ ];

      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+Shift+Left".action.move-column-left = [ ];
      "Mod+Shift+Right".action.move-column-right = [ ];

      "Mod+Up".action.focus-window-or-workspace-up = [ ];
      "Mod+Down".action.focus-window-or-workspace-down = [ ];
      "Mod+Shift+Up".action.move-window-up = [ ];
      "Mod+Shift+Down".action.move-window-down = [ ];

      "Print".action.screenshot = { };
      "Mod+Print".action.screenshot-screen = { };
      "Mod+Shift+Print".action.screenshot-window = { };
    };

    window-rules = [
      {
        draw-border-with-background = false;
        geometry-corner-radius = {
          top-left = 18.0;
          top-right = 18.0;
          bottom-left = 18.0;
          bottom-right = 18.0;
        };
        clip-to-geometry = true;
      }
    ];

    xwayland-satellite = {
      enable = true;
      path = lib.getExe pkgs.xwayland-satellite;
    };
  };

  # niri-flake 的 settings 渲染库（内部文件，fixpoint：settings 参数即渲染库自身；
  # 若 niri-flake 上游变更该接口，此处需要同步）
  niriSettingsLib = import (inputs.niri + "/settings.nix") {
    inherit lib;
    inherit (inputs.niri.lib) kdl;
    inputs = inputs.niri.inputs;
    binds = _: [ ];
    docs = null;
    settings = niriSettingsLib;
  };

  renderedSettings = inputs.niri.lib.kdl.serialize.nodes (
    niriSettingsLib.render config.programs.niri.settings
  );
in
{
  programs.niri = {
    enable = true;
    package = pkgs.niri;
    settings = niriSettings;
    config = ''
      ${renderedSettings}

      include optional=true "~/.config/niri/monet.kdl"
    '';
  };
}
