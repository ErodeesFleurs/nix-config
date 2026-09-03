# 通用硬件支持（主机特定项：NVIDIA、VDPAU 在各 host 中设置）
{ lib, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-tools
      libva
      libva-utils
    ];
    extraPackages32 = [ pkgs.pkgsi686Linux.vulkan-loader ];
  };

  environment.sessionVariables.LIBVA_DRIVER_NAME = lib.mkDefault "auto";
  environment.systemPackages = with pkgs; [
    mesa-demos
    vulkan-tools
  ];

  # 打印（gutenprint 通用驱动；无三星打印机，splix 已移除）
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint ];
  };

  # Logitech 无线设备
  hardware.logitech.wireless.enable = true;
  programs.solaar.enable = true;

  # 电源管理：ppd 全权负责；不与 powertop --auto-tune 并存
  # （auto-tune 开机全局写 sysfs 且无模式感知，会覆盖 ppd performance 档）
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;

  # GVFS（可移动设备访问）
  services.gvfs.enable = true;

  # SSD 每周 TRIM
  services.fstrim.enable = true;

  # 固件更新（LVFS）
  services.fwupd.enable = true;

  # zstd 压缩的内存交换（默认算法即 zstd）
  zramSwap.enable = true;
}
