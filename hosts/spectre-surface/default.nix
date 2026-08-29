# Spectre Surface 主机配置（共享配置在 ../common/）
{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./impermanence.nix
    ./users.nix
    ../common
    # nixos-hardware Surface Pro (Intel) 配置：surface 补丁内核（IPTS 触屏/笔）、
    # iptsd、thermald（Surface 定制）、mem_sleep_default=deep、surface-control。
    # 其 kernelPackages 为普通优先级，覆盖 common/boot.nix 的 mkDefault。
    inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
  ];

  modules.network.wlan.host-name = "spectre-surface";

  # surface 内核跟踪最新稳定版（另一档 longterm 跟踪 LTS）
  hardware.microsoft-surface.kernelVersion = "stable";

  # 无线网络省电模式关闭（Surface 网卡稳定性；
  # 原 NetworkManager wifi.powersave=false 的 udev 等价物）
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="${pkgs.iw}/bin/iw dev $name set power_save off"
  '';
}
