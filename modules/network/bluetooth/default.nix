{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.network.bluetooth;
in
{
  options.modules.network.bluetooth = {
    enable = mkEnableOption "Bluetooth support";

    enable-blueman = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Blueman Bluetooth manager";
    };

    power-on-boot = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to power on Bluetooth adapters on boot";
    };
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = cfg.power-on-boot;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    services.blueman.enable = mkIf cfg.enable-blueman true;

    # 添加蓝牙相关工具到系统包
    environment.systemPackages =
      with pkgs;
      mkIf cfg.enable-blueman [
        bluez
        bluez-tools
      ];
  };
}
