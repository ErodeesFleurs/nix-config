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

  # 打印
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      hplip
      gutenprint
      splix
    ];
  };

  # Logitech 无线设备
  hardware.logitech.wireless.enable = true;
  programs.solaar.enable = true;

  # 电源管理
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  services.power-profiles-daemon.enable = true;

  # GVFS（可移动设备访问）
  services.gvfs.enable = true;
}
