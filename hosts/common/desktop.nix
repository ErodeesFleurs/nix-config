# 桌面环境：compositor、portal、音频、键盘输入（greeter 由 modules.display-manager.tuigreet 提供）
# （纯 Wayland 会话：无 X server；输入设备与键盘布局在 niri 配置中设置）
{ lib, pkgs, ... }:

{
  # niri-flake 的 NixOS 模块无条件开启系统级 gnome-keyring；
  # 密钥环已由 oo7 取代（home/system/keyring.nix），强制关闭
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  # niri 合成器（niri-flake 模块）
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
  environment.systemPackages = with pkgs; [ xwayland-satellite ];
  # 不附带 perl/nano 等默认包
  environment.defaultPackages = lib.mkForce [ ];

  # XDG portals：系统层只提供开关；
  # portal 后端包与接口路由由 home/desktop/xdg.nix 单一管理
  # （home 层 ~/.config/xdg-desktop-portal 优先于 /etc，系统层配置是死配置）
  xdg.portal = {
    enable = true;
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

  # iwd 下 geoclue 的 WiFi 源无法扫描 AP；geoclue 2.8 的 IP 源需显式 method，
  # NixOS 模块未生成 [ip] 段（method=null → 源被禁用，darkman/Firefox 定位超时）。
  # etc text 是 lines 类型，此段会并入模块生成的 geoclue.conf（复用 wifi 的 beacondb url）
  environment.etc."geoclue/geoclue.conf".text = ''
    [ip]
    enable=true
    method=ichnaea
  '';

  # Qt ≥6.5 内置平台主题：读 Settings portal 的 color-scheme，昼夜自动跟随。
  # 输入法不设 QT_IM_MODULE：Qt6 Wayland 原生 text-input-v3
  # （Qt → niri → input-method-v2 → fcitx5 waylandFrontend）；
  # X11 应用由 XMODIFIERS=@im=fcitx 走 XIM 兜底
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
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
