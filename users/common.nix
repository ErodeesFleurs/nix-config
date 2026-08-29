# Fleurs 用户共享配置（各用户文件仅保留差异项）
{ pkgs, ... }:

{
  home = {
    username = "fleurs";
    homeDirectory = "/home/fleurs";
    stateVersion = "26.05";
  };

  homeModules = {
    terminal = {
      shell.nushell = {
        enable = true;
        show-banner = false;
        enable-carapace-integration = true;
      };
      yazi = {
        enable = true;
        enableNushellIntegration = true;
      };
      btop.enable = true;
    };

    helix = {
      enable = true;
      default-editor = true;
    };
    zed.enable = true;
    direnv = {
      enable = true;
      enable-nushell-integration = true;
    };

    desktop = {
      awww.enable = true;
      waybar.enable = true;
      darkman = {
        enable = true;
        # geoclue 自动定位（替代硬编码经纬度）
        useGeoclue = true;
        # builtins.path 单独拷贝入 store（按内容寻址），避免仓库改动触发主题重建
        light.wallpaper = builtins.path {
          path = ../assets/wallpaper.jpg;
          name = "wallpaper.jpg";
        };
        dark.wallpaper = builtins.path {
          path = ../assets/wallpaper.jpg;
          name = "wallpaper.jpg";
        };
      };
    };

    application.playerctl.enable = true;

    firefox = {
      enable = true;
      profile-name = "fleurs";
      force-extensions = true;
    };
    nemo.enable = true;
    mpv.enable = true;
    obs.enable = true;
    starbound.enable = true;
    discord = {
      enable = false;
      vesktop.enable = true;
    };

    mako.enable = true;
    easyeffects.enable = true;
    keyring.enable = true;
    vicinae.enable = true;
    packages.enable = true;
  };

  xdg = {
    enable = true;
    userDirs.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "firefox.desktop";
      };
    };
  };

  # 启用 Home Manager 自管理
  programs.home-manager.enable = true;

  # 锁屏（monet 主题由主题系统链接到 ~/.config/hypr/hyprlock.conf）
  programs.hyprlock.enable = true;

  # 空闲管理：5 分钟锁屏，10 分钟关屏
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "niri msg action power-on-monitors";
      };
      listeners = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "niri msg action power-off-monitors";
          on-resume = "niri msg action power-on-monitors";
        }
      ];
    };
  };
}
