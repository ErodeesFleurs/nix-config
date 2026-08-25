{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ../common/network.nix
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
    substituters = [ "https://cache.nixos.org" ];
    trusted-public-keys = [ ];
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
        "config.mihomo.yaml" = {
          file = ../../secrets/config.mihomo.yaml.age;
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
      vdpau.enable = false;
    };

    power.enable = true;

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

  # 桌面环境
  modules.display-manager = {
    tuigreet.enable = true;
  };

  modules.compositor = {
    niri.enable = true;
  };

  modules.xserver = {
    enable = true;
    video-drivers = [ "modesetting" ];
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

  # 音频配置
  modules.pipewire = {
    enable = true;
    alsa-32bit = true;
    pulse = true;
  };

  # 网络配置（共享配置在 ./common/network.nix，此处仅覆盖主机特定项）
  modules.network.wlan.host-name = "spectre-surface";
  networking.networkmanager.wifi.powersave = false;

  # 游戏配置
  modules.programs.gaming.enable = true;
  modules.programs.steam.enable = true;

  modules.programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extra-args = "--keep-since 7d --keep 3";
    };
  };

  modules.programs.localsend.enable = true;

}
