{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
  ];

  # ==========================================
  # 系统基础配置
  # ==========================================
  system.stateVersion = "26.05";

  modules.nix = {
    enable = true;
    trusted-users = [ "fleurs" ];
    auto-gc = false; # 使用 nh 来管理垃圾回收
    auto-optimise = true;
    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  modules.security = {
    sudo = {
      enable = true;
      use-rust = true;
      enable-polkit = true;
      wheel-needs-password = true;
      extra-rules = [ ];
    };

    agenix = {
      identity-paths = [
        "/home/fleurs/.ssh/id_ed25519"
        "/home/fleurs/.ssh/dae_ed25519"
      ];

      secrets = {
        "config.dae" = {
          file = ../../secrets/config.dae.age;
        };
      };
    };
  };

  modules.etc = {
    state-version = "26.05";
    enable = true;
    enable-init = true;
    overlay-mutable = false;
  };

  # 安装 surface-control
  environment.systemPackages = with pkgs; [
    surface-control
  ];

  # ==========================================
  # 本地化配置
  # ==========================================
  modules.localization = {
    enable = true;
    default-locale = "zh_CN.UTF-8";
    supported-locales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
    extra-locale-settings = { };
    apply-to-all = true;

    input-methods = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        wayland-frontend = true;
        addons = with pkgs; [
          fcitx5-gtk
          kdePackages.fcitx5-qt
          qt6Packages.fcitx5-chinese-addons
          fcitx5-material-color
          fcitx5-pinyin-moegirl
          fcitx5-pinyin-zhwiki
        ];
      };
    };

    fonts = {
      enable = true;
      enable-default-packages = true;
      font-dir = {
        enable = true;
      };
      fontconfig = {
        enable = true;
      };
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji

        font-awesome

        source-code-pro
        source-han-sans
        source-han-serif
        source-han-mono

        sarasa-gothic

        corefonts

        wqy_microhei
        wqy_zenhei

        nerd-fonts.caskaydia-cove
        nerd-fonts.caskaydia-mono
        nerd-fonts.symbols-only
      ];
    };

    time = {
      enable = true;
      time-zone = "Asia/Shanghai";
    };
  };

  # ==========================================
  # 启动配置
  # ==========================================
  modules.boot = {
    enable = true;
    use-latest-kernel = true;
    enable-systemd-boot = true;
    enable-systemd-initrd = true;
    efi-can-touch-variables = true;
    enable-iommu = false;
    extra-kernel-params = [
      "mem_sleep_default=deep" # 深度睡眠模式
    ];
  };

  # ==========================================
  # 硬件配置（Surface Pro 5 使用 Intel 集显）
  # ==========================================
  modules.hardware = {
    graphics = {
      enable = true;
      enable-32bit = true;
      vulkan.enable = true;
      vaapi.enable = true;
      vdpau.enable = false; # Intel 不需要 VDPAU
    };

    power = {
      enable = true;
      enable-tlp = true;
      enable-powertop = true;
      enable-upower = true;
    };

    printing = {
      enable = true;
      service = {
        enable = true;
      };
      drivers = with pkgs; [
        hplip
        gutenprint
        splix
      ];
    };

    storage = {
      enable = true;
      gvfs = {
        enable = true;
      };
    };

    logitech = {
      enable = true;
      wireless = {
        enable = true;
        enable-graphical = true;
      };
    };
  };

  # ==========================================
  # 桌面环境
  # ==========================================
  modules.display-manager = {
    enable = true;
    wayland = true;
    auto-numlock = false;
  };

  modules.programs.hyprland = {
    enable = true;
    xwayland = true;
  };

  modules.xserver = {
    enable = true;
    video-drivers = [ "modesetting" ]; # Intel 集显使用 modesetting
    layout = "cn";
    libinput = {
      enable = true;
      touchpad = {
        natural-scrolling = true;
        tapping = true;
        disable-while-typing = true;
      };
    };
  };

  modules.xdg.enable = true;

  # ==========================================
  # 音频配置
  # ==========================================
  modules.pipewire = {
    enable = true;
    alsa-32bit = true;
    pulse = true;
  };

  # ==========================================
  # 网络配置
  # ==========================================
  modules.network = {
    wlan = {
      enable = true;
      host-name = "spectre-surface";
      enable-nm-applet = true;
      show-indicator = true;
      enable-firewall = true;
    };
    bluetooth = {
      enable = true;
      enable-blueman = true;
      power-on-boot = true;
    };

    ssh = {
      enable = true;
      enable-server = false;
      enable-agent = true;
      known-hosts = {
        "github.com".publicKey =
          "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
    };

    dns = {
      enable = true;
      enable-service = true;
      listen-addrs = [ "127.0.0.1" ];
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

    resolver = {
      enable = true;
      enable-resolved = true;
      enable-resolvconf = false;
    };

    v2ray = {
      enable = true;
      port = 1080;
      listen-address = "127.0.0.1";
      protocol = "socks";
      enable-udp = true;
      enable-v2raya = true;
    };

    dae = {
      enable = true;
      enable-daed = false;
    };
  };

  # 防止休眠后 WIFI 无法连接的问题
  networking.networkmanager.wifi.powersave = false;

  # ==========================================
  # 游戏配置
  # ==========================================
  modules.programs.gaming = {
    enable = true;
    enable-gamemode = true;
    enable-performance-optimizations = true;
    wine.enable = false;
  };

  modules.programs.steam = {
    enable = true;
    remote-play = {
      enable = true;
      open-firewall = true;
    };
    dedicated-server = {
      enable = true;
      open-firewall = true;
    };
    extest = true;
    gamescope-session = true;
    protontricks = true;
  };

  modules.programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extra-args = "--keep-since 7d --keep 3";
    };
  };

  modules.programs.localsend.enable = true;

  # ==========================================
  # 主题配置
  # ==========================================
  modules.stylix = {
    enable = true;
    polarity = "light";
    base16-scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-light-soft.yaml";
  };
}
