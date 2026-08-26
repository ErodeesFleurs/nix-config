{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.network.bluetooth;
in
{
  options.modules.network.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support";

    enable-blueman = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Blueman Bluetooth manager";
    };

    power-on-boot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to power on Bluetooth adapters on boot";
    };
  };

  config = lib.mkIf cfg.enable {
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

    services.blueman.enable = lib.mkIf cfg.enable-blueman true;

    # 添加蓝牙相关工具到系统包
    environment.systemPackages =
      with pkgs;
      lib.mkIf cfg.enable-blueman [
        bluez
        bluez-tools
      ];
  };
}
