# 通用硬件支持（主机特定项：NVIDIA、VDPAU 在各 host 中设置）
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

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

  # Logitech：使用 nixpkgs 内置模块安装 OpenLogi 及设备访问规则；agent 服务在下方声明。
  # 不与 Solaar 同时运行，避免争用 HID++；不再安装旧 ltunify 管理工具。
  programs.openlogi = {
    enable = true;
    # 保留官方源码和内置主题，不做 Monet 补丁；避免使用 nixpkgs 较旧版本降级。
    package = inputs.openlogi.packages.${pkgs.stdenv.hostPlatform.system}.openlogi.overrideAttrs (old: {
      # cargo setup 强制使用系统 zstd；工作区测试的 xtask 需要 libzstd.pc。
      checkInputs = (old.checkInputs or [ ]) ++ [ pkgs.zstd ];
    });
  };

  # nixpkgs 内置模块不创建 agent 服务；保留随图形会话启动和退出的生命周期。
  systemd.user.services.openlogi-agent = {
    description = "OpenLogi background agent";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = lib.getExe' config.programs.openlogi.package "openlogi-agent";
      Restart = "on-failure";
      RestartSec = 5;
    };
    # Actions Ring 子进程也需要图形库，不能只依赖主界面的 RPATH。
    environment.LD_LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.wayland
      pkgs.vulkan-loader
      pkgs.libGL
    ];
  };

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
