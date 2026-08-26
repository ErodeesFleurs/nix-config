# 桌面环境：compositor、portal、音频、键盘输入（greeter 由 modules.display-manager.tuigreet 提供）
# （主机特定项：services.xserver.videoDrivers、libinput 触摸板在各 host 中设置）
{ pkgs, ... }:

{
  # niri 合成器（niri-flake 模块）
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
  environment.defaultPackages = with pkgs; [ xwayland-satellite ];

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

  # X server 公共部分（videoDrivers 按主机设置）
  services.xserver = {
    enable = true;
    xkb.layout = "cn";
  };
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      disableWhileTyping = true;
    };
  };
}
