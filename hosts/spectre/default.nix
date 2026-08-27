# Spectre 主机配置（共享配置在 ../common/）
{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ../common
  ];

  modules.network.wlan.host-name = "spectre";

  # IOMMU（虚拟化）
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
  ];

  # NVIDIA 显卡（PRIME offload：AMD 核显 + NVIDIA 独显）
  modules.hardware.nvidia = {
    enable = true;
    modesetting = true;
    open = true;
    nvidia-settings = true;
    package = "stable";
    power-management = {
      enable = true;
      finegrained = true;
    };
    prime = {
      enable = true;
      offload = {
        enable = true;
        enable-offload-cmd = true;
      };
      amdgpu-bus-id = "PCI:0:6:0";
      nvidia-bus-id = "PCI:0:1:0";
    };
    apply-patches = false;
  };
  # 注意：nixpkgs 的 hardware.nvidia 模块以 videoDrivers 成员作为驱动栈启用开关
  # （nvidiaEnabled = elem "nvidia" videoDrivers，与 services.xserver.enable 无关）。
  # 不启用 X server，但必须保留此项以激活驱动配置（settings/EGL/PRIME/电源管理）。
  services.xserver.videoDrivers = [ "nvidia" ];

  # VDPAU 视频加速
  hardware.graphics.extraPackages = with pkgs; [
    vdpauinfo
    libvdpau-va-gl
  ];
  environment.sessionVariables.VDPAU_DRIVER = lib.mkDefault "auto";

  # Podman 容器
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  users.users.fleurs = {
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };
  environment.etc = {
    "subuid".text = "fleurs:100000:65536\n";
    "subgid".text = "fleurs:100000:65536\n";
  };
  environment.systemPackages = with pkgs; [ podman-compose ];

  # AppImage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
