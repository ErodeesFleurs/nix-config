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
  networking.hostName = "spectre";
  system.stateVersion = "26.05";

  modules.system = {
    enable = true;
    autoGC = false; # 使用 nh 来管理垃圾回收
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 3";
      };
    };
    sudo = {
      enable = true;
      useRust = true;
      enablePolkit = true;
    };
    enableInit = true;
    overlayMutable = true;
  };

  modules.i18n.enable = true;

  # ==========================================
  # 启动配置
  # ==========================================
  modules.system.boot = {
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

  modules.hardware.nvidia-container = {
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

  modules.hyprland = {
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
    hostName = "spectre";
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
    enableServer = true;
    enableAgent = true;
    knownHosts = {
      "github.com".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICXZT5BZTeDTgIk2oEOiZwjtrSLwlnD6tCla410rGut 862959461@qq.com";
    };
    serverSettings = {
      permitRootLogin = "prohibit-password";
      passwordAuthentication = false;
      port = 22;
    };
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
  # 游戏配置
  # ==========================================
  modules.games = {
    enable = true;
    enableGamemode = true;
    enablePerformanceOptimizations = true;
    wine.enable = true;
    steam = {
      enable = true;
      remotePlay.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.enable = true;
      dedicatedServer.openFirewall = true;
      extest = true;
      gamescopeSession = true;
      protontricks = true;
    };
  };
}
