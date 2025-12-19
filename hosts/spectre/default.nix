# Spectre 主机配置
{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
  ];

  # ==========================================
  # 系统基础配置
  # ==========================================

  modules.nix = {
    enable = true;
    trusted-users = [ "fleurs" ];
    auto-gc = false; # 使用 nh 来管理垃圾回收
    auto-optimise = true;
    substituters = [ "https://cache.nixos.org" ];
    trusted-public-keys = [ ];
  };

  modules.security.sudo = {
    enable = true;
    use-rust = true;
    enable-polkit = true;
    wheel-needs-password = true;
    extra-rules = [ ];
  };

  # /etc related options moved to modules.etc
  modules.etc = {
    state-version = "26.05";
    enable = true;
    enable-init = true;
    overlay-mutable = false;
  };

  modules.localization = {
    enable = true;
    default-locale = "zh_CN.UTF-8";
    supported-locales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
    extra-locale-settings = { };
    apply-to-all = true;
  };

  # ==========================================
  # 启动配置
  # ==========================================
  modules.boot = {
    enable = true;
    useLatestKernel = true;
    enableSystemdBoot = true;
    enableSystemdInitrd = true;
    efiCanTouchVariables = true;
    enableIOMMU = true;
  };

  # ==========================================
  # 硬件配置
  # ==========================================
  modules.hardware.graphics = {
    enable = true;
    enable32Bit = true;
    vulkan.enable = true;
    vaapi.enable = true;
    vdpau.enable = true;
  };

  modules.hardware.nvidia = {
    enable = true;
    modesetting = true;
    open = true;
    nvidiaSettings = true;
    package = "stable";
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = {
      enable = true;
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:0:6:0";
      nvidiaBusId = "PCI:0:1:0";
    };
    applyPatches = true;
  };

  modules.hardware.nvidiaContainer = {
    enable = true;
  };

  # ==========================================
  # 桌面环境
  # ==========================================
  modules.display-manager = {
    enable = true;
    wayland = true;
    autoNumlock = true;
  };

  modules.programs.hyprland = {
    enable = true;
    xwayland = true;
    withUWSM = true;
  };

  modules.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    layout = "cn";
    libinput.enable = true;
  };

  modules.xdg = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  # ==========================================
  # 音频配置
  # ==========================================
  modules.pipewire = {
    enable = true;
    alsa32Bit = true;
    pulse = true;
  };

  # ==========================================
  # 网络配置
  # ==========================================
  modules.network.wlan = {
    enable = true;
    host-name = "spectre";
    enableNmApplet = true;
    showIndicator = true;
    enableFirewall = true;
  };

  modules.network.bluetooth = {
    enable = true;
    enableBlueman = true;
    powerOnBoot = true;
  };

  modules.network.ssh = {
    enable = true;
    enableServer = false;
    enableAgent = true;
    knownHosts = {
      "github.com".publicKey =
        "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
    serverSettings = {
      permitRootLogin = "prohibit-password";
      passwordAuthentication = false;
      port = 22;
    };
  };

  modules.network.dns = {
    enable = true;
    enable-service = true;
    listenAddrs = [ "127.0.0.1" ];
    bootstrap = [
      "127.2.0.17"
      "8.8.8.8"
      "119.29.29.29"
      "114.114.114.114"
      "223.6.6.6"
    ];
    upstream = [
      "tls://1.1.1.1"
      "quic://dns.alidns.com"
      "h3://dns.alidns.com/dns-query"
      "tls://dot.pub"
      "https://doh.pub/dns-query"
    ];
  };

  modules.network.resolver = {
    enable = true;
    enableResolved = true;
    enableResolvconf = true;
    preferResolved = true;
  };

  modules.network.v2ray = {
    enable = true;
    port = 1080;
    listenAddress = "127.0.0.1";
    protocol = "socks";
    enableUDP = true;
    enableV2rayA = true;
  };

  # ==========================================
  # 主题配置
  # ==========================================
  modules.stylix = {
    enable = true;
    polarity = "light";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-light-hard.yaml";
  };

  # ==========================================
  # 游戏配置（已迁移到 programs 命名空间）
  # ==========================================
  modules.programs.gaming = {
    enable = true;
    enableGamemode = true;
    enablePerformanceOptimizations = true;
    wine.enable = true;
  };

  modules.programs.steam = {
    enable = true;
    remotePlay.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.enable = true;
    dedicatedServer.openFirewall = true;
    extest = true;
    gamescopeSession = true;
    protontricks = true;
  };

  # nh: moved to modules.programs.nh
  modules.programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
  };
}
