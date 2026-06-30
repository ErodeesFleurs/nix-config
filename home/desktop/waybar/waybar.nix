{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home-modules.desktop.waybar;
  m3FallbackStyle = builtins.readFile ../../../assets/waybar/m3-expressive-dark.css;
in
{
  options.home-modules.desktop.waybar = {
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
            "tray"
            "network"
            "cpu"
            "memory"
            "battery"
            "mpris"
          ];

          "niri/window" = {
            format = "{title}";
            max-length = 50;
            tooltip = false;
            seperate-outputs = true;
          };

          clock = {
            format = "{:%b %d  %H:%M}";
            tooltip-format = "{:%A, %Y (%S)}";
            interval = 1;
            on-click = "vicinae toggle";
            # on-click-right = "fuzzel-logout-menu";
          };

          mpris = {
            format = "󰎇 {dynamic}";
            dynamic-order = [
              "artist"
              "title"
            ];
            max-length = 30;
            tooltip-format = "{status}";
            on-scroll-up = "playerctl volume 0.10+";
            on-scroll-down = "playerctl volume 0.10-";
          };

          "tray" = {
            icon-size = 16;
            spacing = 12;
          };

          network = {
            interval = 5;
            format = "{ifname}";
            format-wifi = "{icon} {essid}";
            format-ethernet = " {ifname}";
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
            exec = ''
              if [ "$(readlink ${config.home.homeDirectory}/.local/share/themes/current)" = dark ]; then
                printf '{"text":"󰖔","tooltip":"Night mode — click for day","class":"dark"}'
              else
                printf '{"text":"󰖨","tooltip":"Day mode — click for night","class":"light"}'
              fi
            '';
            interval = 10;
            return-type = "json";
            on-click = ''
              CURRENT=$(readlink ${config.home.homeDirectory}/.local/share/themes/current)
              if [ "$CURRENT" = dark ]; then
                if ${pkgs.darkman}/bin/darkman set light 2>/dev/null; then
                  :
                else
                  ${config.home.homeDirectory}/.local/share/darkman/switch-theme.sh light
                fi
              else
                if ${pkgs.darkman}/bin/darkman set dark 2>/dev/null; then
                  :
                else
                  ${config.home.homeDirectory}/.local/share/darkman/switch-theme.sh dark
                fi
              fi
            '';
          };
        };
      };
      style = m3FallbackStyle;
    };
  };
}
