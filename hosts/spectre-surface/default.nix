# Spectre Surface 主机配置（共享配置在 ../common/）
{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./impermanence.nix
    ./users.nix
    ../common
  ];

  modules.network.wlan.host-name = "spectre-surface";

  # 无线网络省电模式关闭（Surface 网卡稳定性；
  # 原 NetworkManager wifi.powersave=false 的 udev 等价物）
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="${pkgs.iw}/bin/iw dev $name set power_save off"
  '';

  environment.systemPackages = with pkgs; [ surface-control ];
}
