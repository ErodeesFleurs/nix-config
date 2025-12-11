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

  # Surface 特定服务
  services.iptsd.enable = true;

  # 安装 surface-control
  environment.systemPackages = with pkgs; [
    surface-control
  ];

  modules.i18n.enable = true;

  # ==========================================
  # 启动配置
  # ==========================================
  modules.system.boot = {
    enable = true;
    useLatestKernel = false; # Surface 使用硬件模块推荐的内核
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
    enable32Bit = false; # Surface 不需要 32 位支持
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

  modules.hyprland = {
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
      # 触摸屏和触摸板优化
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
    alsa32Bit = false; # 平板不需要 32 位音频
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

  # 禁用 WiFi 省电模式以解决休眠唤醒问题
  networking.networkmanager.wifi.powersave = false;

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
  # 电源管理（平板设备重要）
  # ==========================================
  modules.system.power = {
    enable = true;
    enableTlp = true; # 电池优化
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
