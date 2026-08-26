# Spectre Surface 主机配置（共享配置在 ../common/）
{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ../common
  ];

  modules.network.wlan.host-name = "spectre-surface";

  # Surface Pro 5 使用 Intel 集显
  services.xserver.videoDrivers = [ "modesetting" ];
  services.libinput.touchpad.naturalScrolling = true;

  # 无线网络省电模式关闭（Surface 网卡稳定性）
  networking.networkmanager.wifi.powersave = false;

  environment.systemPackages = with pkgs; [ surface-control ];
}
