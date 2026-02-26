{ config, lib, ... }:
let
  cfg = config.homeModules.desktop.hyprland.lock;
in
{
  options.homeModules.desktop.hyprland.lock = {
    enable = lib.mkEnableOption "Hyprlock screen locker configuration for Home Manager";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          no_fade_in = false;
          no_fade_out = false;
          hide_cursor = true;
          grace = 0;
          disable_loading_bar = true;
          ignore_empty_input = true;
        };

        input-field = {
          monitor = "";
          size = "250, 60";
          outline_thickness = 2;
          dots_size = 0.2; # 输入字段高度的比例，0.2 - 0.8
          dots_spacing = 0.35; # 点的绝对大小比例，0.0 - 1.0
          dots_center = true;

          fade_on_empty = false;
          rounding = -1;
          placeholder_text = "<span foreground=\"##cdd6f4\">Password</span>";
          hide_input = false;
          position = "0, -200";
          halign = "center";
          valign = "center";

          fail_text = "<b>$ATTEMPTS</b>"; # 可以设置为空
          fail_timeout = 2000; # fail_text 和 fail_color 消失前的毫秒数
          fail_transition = 300; # outer_color 和 fail_color 之间的过渡时间（以毫秒为单位）
        };
        label = [
          #日期
          {
            monitor = "";
            text = "cmd[update:1000] date +\"%A, %B %d\"";
            color = "rgb(205, 214, 244)";
            font_size = "22";
            font_family = "Caskaydia Mono";
            position = "0, 300";
            halign = "center";
            valign = "center";
          }
          #时间
          {
            monitor = "";
            text = "cmd[update:1000]  date +\"%-I:%M\"";
            color = "rgb(205, 214, 244)";
            font_size = 95;
            font_family = "Caskaydia Mono";
            position = "0, 200";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
