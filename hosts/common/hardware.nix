# 通用硬件支持（主机特定项：NVIDIA、VDPAU 在各 host 中设置）
{ lib, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      libva
    ];
    extraPackages32 = [ pkgs.pkgsi686Linux.vulkan-loader ];
  };

  environment.sessionVariables.LIBVA_DRIVER_NAME = lib.mkDefault "auto";
  environment.systemPackages = with pkgs; [
    mesa-demos
    vulkan-tools
    libva-utils
  ];

  # 打印（gutenprint 通用驱动；无三星打印机，splix 已移除）
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint ];
  };

  # Logitech：OpenLogi 模块提供设备访问规则和随图形会话启动的后台服务。
  # 不与 Solaar 同时运行，避免争用 HID++；不再安装旧 ltunify 管理工具。
  programs.openlogi.enable = true;

  # 上游 0.8.13 仅为主界面设置图形库 RPATH；Actions Ring 子进程也需要它们。
  systemd.user.services.openlogi-agent.environment.LD_LIBRARY_PATH = lib.makeLibraryPath [
    pkgs.wayland
    pkgs.vulkan-loader
    pkgs.libGL
  ];

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
