{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeModules.desktop.waybar;
  m3FallbackStyle = builtins.readFile ../../../assets/waybar/m3-expressive-dark.css;
in
{
  options.homeModules.desktop.waybar = {
    enable = lib.mkEnableOption "Waybar configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;

      systemd = {
        enable = true;
        enableInspect = false;
      };

      settings = {
        main = {
          position = "top";
          layer = "top";
          exclusive = true;
          gtk-layer-shell = false;
          start_hidden = false;
          reload_style_on_change = true;
          height = 38;
          spacing = 2;
          modules-left = [
            "niri/workspaces"
            "niri/window"
          ];
          modules-center = [
            "clock"
          ];
          modules-right = [
            "custom/darkman"
            "idle_inhibitor"
            "tray"
            "network"
            "wireplumber"
            "backlight"
            "cpu"
            "memory"
            "battery"
            "mpris"
          ];

          "niri/window" = {
            format = "{title}";
            max-length = 50;
            tooltip = false;
            separate-outputs = true;
            # 标题美化：剥掉应用后缀并补图标
            rewrite = {
              "^(.*) — Mozilla Firefox$" = " $1";
            };
          };

          clock = {
            format = "{:%b %d  %H:%M}";
            tooltip-format = "{:%A, %Y (%S)}";
            interval = 1;
            on-click = "vicinae toggle";
          };

          mpris = {
            format = "󰎇 {dynamic}";
            dynamic-order = [
              "artist"
              "title"
            ];
            max-length = 30;
            tooltip-format = "{status}";
            on-click = "playerctl play-pause";
            on-scroll-up = "playerctl volume 0.10+";
            on-scroll-down = "playerctl volume 0.10-";
          };

          "tray" = {
            icon-size = 16;
            spacing = 12;
          };

          wireplumber = {
            format = "{icon} {volume}%";
            format-muted = "󰝟 muted";
            format-icons = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
            scroll-step = 5;
            tooltip-format = "{node_name}\nVolume: {volume}%";
            tooltip-format-muted = "{node_name}\nMuted";
            on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            on-click-right = "${pkgs.pwvucontrol}/bin/pwvucontrol";
          };

          # 背光（滚轮调节亮度，与音量滚轮对称）
          backlight = {
            format = "{icon} {percent}%";
            format-icons = [
              "󰃚"
              "󰃛"
              "󰃜"
              "󰃝"
              "󰃞"
              "󰃟"
              "󰃠"
            ];
          };

          # 空闲抑制（一键暂停 hypridle 自动锁屏/关屏）
          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = "󰅶";
              deactivated = "󰾪";
            };
            tooltip-format-activated = "空闲抑制已开启 — 点击恢复自动锁屏";
            tooltip-format-deactivated = "空闲抑制已关闭 — 点击暂停自动锁屏";
          };

          network = {
            interval = 5;
            format = "{ifname}";
            format-wifi = "{icon} {essid}";
            format-ethernet = "󰈀 {ifname}";
            format-disconnected = "󰤮 disconnected";
            format-disabled = "󰤭 disabled";
            format-icons = [
              "󰤯"
              "󰤟"
              "󰤢"
              "󰤥"
              "󰤨"
            ];
            tooltip-format = "{ifname} - {ipaddr}\nDown Speed: {bandwidthDownBytes}\nUp Speed: {bandwidthUpBytes}";
            on-click-right = "ghostty -e nmtui";
          };

          cpu = {
            interval = 10;
            format = " {usage}%";
            max-length = 10;
            on-click-right = "ghostty -e btop";
          };

          memory = {
            interval = 10;
            format = " {}%";
            max-length = 10;
            on-click-right = "ghostty -e btop";
          };

          battery = {
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-icons = [
              "󰂎"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            tooltip-format = "{timeTo}";
            states = {
              warning = 30;
              critical = 10;
            };
            interval = 30;
          };

          "custom/darkman" = {
            # darkman watch：事件驱动（启动时立即打印当前模式，切换时逐行推送）
            exec = ''
              ${pkgs.darkman}/bin/darkman watch | while read -r mode; do
                if [ "$mode" = "dark" ]; then
                  printf '{"text":"󰖔","tooltip":"夜间模式 — 点击切换日间","class":"dark"}\n'
                else
                  printf '{"text":"󰖨","tooltip":"日间模式 — 点击切换夜间","class":"light"}\n'
                fi
              done
            '';
            return-type = "json";
            on-click = "${pkgs.darkman}/bin/darkman toggle";
          };
        };
      };
      style = m3FallbackStyle;
    };
  };
}
