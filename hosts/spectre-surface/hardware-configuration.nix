# Surface Pro 5 硬件配置

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
  # 文件系统
  # ==========================================
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2b6178d3-cd6a-4fad-b8c4-2cb995cd7a0e";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A8ED-7BCF";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8192;
    }
  ];

  # CPU 微码更新
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

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
  hardware.graphics = {
    enable = true;
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
