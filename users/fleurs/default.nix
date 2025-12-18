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
      vscode
      rar
      go-musicfox
      aria2
    ];
  };
  # Shell 配置
  homeModules.terminal.shell.nushell = {
    enable = true;
    showBanner = false;
    enableYaziIntegration = true;
    enableCarapaceIntegration = true;
  };

  # Git 配置
  homeModules.terminal.git = {
    enable = true;
    userName = "ErodeesFleurs";
    userEmail = "862959461@qq.com";
    delta.enable = true;
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
    defaultEditor = true;
  };

  homeModules.zed.enable = true;

  homeModules.direnv = {
    enable = true;
    enableNushellIntegration = true;
  };

  # 桌面环境
  homeModules.hyprland = {
    enable = true;
    systemd = false;
    xwayland = true;
    hyprlauncher = false;
    hyprpolkit = true;
  };

  homeModules.ashell = {
    enable = true;
    systemd = true;
    position = "Top";
    appLauncherCmd = "vicinae toggle";
  };

  # 应用程序
  homeModules.firefox = {
    enable = true;
    profileName = "fleurs";
    forceExtensions = true;
    enableStylix = true;
  };

  homeModules.mpv.enable = true;
  homeModules.obs.enable = true;
  homeModules.starbound.enable = true;

  homeModules.discord = {
    enable = true;
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
    hyprland-tools.enable = true;
  };

  # 环境变量
  homeModules.variables = {
    enable = true;
    browser = "firefox";
    terminal = "ghostty";
  };

  # 主题配置
  homeModules.stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-light-hard.yaml";
  };

  # XDG 配置
  xdg = {
    enable = true;
    userDirs.enable = true;

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
      };
    };
  };

  # 启用 Home Manager 自管理
  programs.home-manager.enable = true;
}
