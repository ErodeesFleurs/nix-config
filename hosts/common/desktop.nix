# 桌面环境：compositor、portal、音频、键盘输入（greeter 由 modules.display-manager.tuigreet 提供）
# （纯 Wayland 会话：无 X server；输入设备与键盘布局在 niri 配置中设置）
{ lib, pkgs, ... }:

{
  # niri 合成器（niri-flake 模块）
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
  environment.systemPackages = with pkgs; [ xwayland-satellite ];
  # 不附带 perl/nano 等默认包
  environment.defaultPackages = lib.mkForce [ ];

  # XDG portals
  xdg.portal = {
    enable = true;
    config.common.default = [ "gtk" ];
    configPackages = [ ];
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = true;
  };
  systemd.user.services.xdg-desktop-portal = {
    after = [ "graphical-session.target" ];
    enableDefaultPath = false;
  };

  programs.dconf.enable = true;

  # darkman 的 geoclue 定位来源（niri 无桌面 agent，启用 demo agent）
  services.geoclue2 = {
    enable = true;
    enableDemoAgent = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_IM_MODULE = "fcitx";
  };

  # PipeWire 音频
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };
}
