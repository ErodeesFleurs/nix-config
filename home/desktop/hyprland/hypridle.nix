{ config, lib, ... }:

let
  cfg = config.homeModules.desktop.hyprland.idle;
in
{
  options.homeModules.desktop.hyprland.idle = {
    enable = lib.mkEnableOption "Hypridle idle management configuration for Home Manager";
  };

  config = lib.mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock"; # 避免启动多个 hyprlock 实例
          before_sleep_cmd = "loginctl lock-session"; # 睡眠前锁定会话
          after_sleep_cmd = "hyprctl dispatch dpms on"; # 避免必须按两次键才能打开显示屏
        };

        listener = [
          {
            timeout = 150; # 2.5 分钟
            on-timeout = "brightnessctl -s set 10"; # 将显示器背光设置为最低，避免 OLED 显示器上显示为 0
            on-resume = "brightnessctl -r"; # 恢复显示器背光
          }

          # {
          #   timeout = 150; # 2.5 分钟
          #   on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0"; # 关闭键盘背光
          #   on-resume = "brightnessctl -rd rgb:kbd_backlight"; # 恢复键盘背光
          # }

          {
            timeout = 300; # 5 分钟
            on-timeout = "loginctl lock-session"; # 锁定会话
          }

          {
            timeout = 330; # 5.5 分钟
            on-timeout = "hyprctl dispatch dpms off"; # 关闭显示屏
            on-resume = "hyprctl dispatch dpms on"; # 打开显示屏
          }

          {
            timeout = 3600; # 60 分钟
            on-timeout = "systemctl suspend"; # 进入睡眠
          }
        ];
      };
    };
  };
}
