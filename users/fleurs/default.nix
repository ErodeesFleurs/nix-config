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

  # 桌面环境
  homeModules.hyprland = {
    enable = false;
    hyprlauncher = false;
  };
  homeModules.hyprpaper = {
    enable = false;
  };

  homeModules.ashell = {
    enable = true;
    systemd = true;
    position = "Top";
    app-launcher-cmd = "vicinae toggle";
  };

  homeModules.desktop.swww = {
    enable = true;
    extra-args = [ ];
  };

  # 应用程序
  homeModules.firefox = {
    enable = true;
    profile-name = "fleurs";
    force-extensions = true;
    enable-stylix = true;
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
    auto-enable = true;
    base16-scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-light-soft.yaml";
  };

  homeModules.thunderbird.enable = true;

  homeModules.others.aseprite.enable = true;

  # XDG 配置
  xdg = {
    enable = true;
    userDirs.enable = true;

    mimeApps = {
      enable = true;
    };
  };

  # 启用 Home Manager 自管理
  programs.home-manager.enable = true;
}
