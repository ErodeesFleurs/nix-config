# Fleurs 用户配置
{ pkgs, ... }:

{
  # 用户基本信息
  home = {
    username = "fleurs";
    homeDirectory = "/home/fleurs";
    stateVersion = "26.05";

    # 特定软件包
    packages = with pkgs; [
      rar
      go-musicfox
      aria2
    ];
  };
  # Shell 配置
  homeModules.terminal.shell.nushell = {
    enable = true;
    show-banner = false;
    enable-carapace-integration = true;
  };

  # Git 配置
  homeModules.terminal.git = {
    enable = true;
    user-name = "ErodeesFleurs";
    user-email = "862959461@qq.com";
    delta.enable = true;
    lfs.enable = true;
  };

  # 终端工具
  homeModules.terminal.yazi = {
    enable = true;
    enableNushellIntegration = true;
  };

  homeModules.terminal.btop.enable = true;

  # 开发工具
  homeModules.helix = {
    enable = true;
    default-editor = true;
  };

  homeModules.zed.enable = true;

  homeModules.direnv = {
    enable = true;
    enable-nushell-integration = true;
  };

  home-modules.application = {
    udiskie.enable = true;
  };

  home-modules.desktop = {
    awww.enable = true;
    waybar.enable = true;
    darkman = {
      enable = true;
      light.wallpaper = ../../assets/wallpaper.jpg;
      dark.wallpaper = ../../assets/wallpaper.jpg;
    };
  };

  # 应用程序
  homeModules.firefox = {
    enable = true;
    profile-name = "fleurs";
    force-extensions = true;
  };

  home-modules.application = {
    playerctl.enable = true;
  };

  homeModules.nemo.enable = true;

  homeModules.mpv.enable = true;
  homeModules.obs.enable = true;
  homeModules.starbound.enable = true;

  homeModules.discord = {
    enable = false;
    vesktop.enable = true;
  };

  # 系统工具
  homeModules.dunst.enable = true;

  homeModules.easyeffects = {
    enable = true;
    autostart = true;
  };

  homeModules.keyring.gnome.enable = true;
  homeModules.vicinae.enable = true;

  homeModules.packages = {
    enable = true;
  };

  # 环境变量
  homeModules.variables = {
    enable = true;
    browser = "firefox";
    terminal = "ghostty";
  };

  homeModules.others.aseprite.enable = false;

  # XDG 配置
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
}
