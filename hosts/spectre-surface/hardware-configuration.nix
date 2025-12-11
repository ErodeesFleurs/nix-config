# Surface Pro 5 硬件配置
# 这是一个模板文件，需要在实际设备上运行以下命令生成真实配置：
# nixos-generate-config --show-hardware-config > hardware-configuration.nix

{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ==========================================
  # 启动配置
  # ==========================================
  boot.initrd.availableKernelModules = [
    "xhci_pci" # USB 3.0
    "nvme" # NVMe SSD
    "usb_storage" # USB 存储
    "sd_mod" # SD 卡
    "rtsx_pci_sdmmc" # 读卡器
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ]; # Intel 虚拟化支持
  boot.extraModulePackages = [ ];

  # ==========================================
  # 文件系统（需要根据实际情况调整）
  # ==========================================
  # 示例配置 - 请运行 nixos-generate-config 获取真实 UUID
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/XXXX-XXXX";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  # CPU 微码更新
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Surface 特定内核模块
  boot.extraModprobeConfig = ''
    # Surface 触摸屏
    options i915 enable_fbc=1 enable_psr=2
  '';

  # 启用固件更新
  hardware.enableRedistributableFirmware = true;

  # ==========================================
  # 网络硬件
  # ==========================================
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  # ==========================================
  # 显示配置
  # ==========================================
  # Surface Pro 5 的高 DPI 屏幕
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  # ==========================================
  # 电源管理
  # ==========================================
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # ==========================================
  # 其他硬件
  # ==========================================
  # 蓝牙
  hardware.bluetooth.enable = true;

  # 声卡
  sound.enable = true;
  hardware.pulseaudio.enable = false; # 使用 PipeWire

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
