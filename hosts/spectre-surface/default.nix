# Surface Pro 5 主机配置
# 针对平板设备优化的轻量级配置
{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
  ];

  # ==========================================
  # 系统基础配置
  # ==========================================
  networking.hostName = "spectre-surface";
  system.stateVersion = "26.05";

  modules.nix = {
    enable = true;
    autoGC = false; # 使用 nh 来管理垃圾回收
  };

  modules.security.sudo = {
    enable = true;
    useRust = true;
    enablePolkit = true;
  };

  # /etc related options moved to modules.etc
  modules.etc = {
    enable = true;
    enableInit = true;
    overlayMutable = false;
  };

  # Surface 特定服务，没装内核没啥用
  services.iptsd.enable = false;

  # 安装 surface-control
  environment.systemPackages = with pkgs; [
    surface-control
  ];

  modules.i18n.enable = true;

  # ==========================================
  # 启动配置
  # ==========================================
  modules.boot = {
    enable = true;
    useLatestKernel = true; # 没用硬件模块推荐的内核，也没那么需要
    enableSystemdBoot = true;
    enableSystemdInitrd = true;
    efiCanTouchVariables = true;
    enableIOMMU = false; # Intel 平台不需要 AMD IOMMU
    extraKernelParams = [
      "mem_sleep_default=deep" # 深度睡眠模式
    ];
  };

  # ==========================================
  # 硬件配置（Surface Pro 5 使用 Intel 集显）
  # ==========================================
  modules.hardware.graphics = {
    enable = true;
    enable32Bit = true;
    vulkan.enable = true;
    vaapi.enable = true;
    vdpau.enable = false; # Intel 不需要 VDPAU
  };

  # ==========================================
  # 桌面环境
  # ==========================================
  modules.display-manager = {
    enable = true;
    wayland = true;
    autoNumlock = false; # 平板设备通常没有数字键盘
  };

  modules.programs.hyprland = {
    enable = true;
    xwayland = true;
    withUWSM = true;
  };

  modules.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ]; # Intel 集显使用 modesetting
    layout = "cn";
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        disableWhileTyping = true;
      };
    };
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
    hostName = "spectre-surface";
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
    enableService = true;
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
  # 电源管理（平板设备重要）
  # ==========================================
  modules.hardware.power = {
    enable = true;
    enableTlp = true; # 电池优化
  };

  # ==========================================
  # 游戏配置
  # ==========================================
  modules.programs.gaming = {
    enable = true;
    enableGamemode = true;
    enablePerformanceOptimizations = true;
    wine.enable = false;
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

  modules.programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
  };

  # ==========================================
  # 主题配置
  # ==========================================
  modules.stylix = {
    enable = true;
    polarity = "light";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-light-hard.yaml";
  };
}
