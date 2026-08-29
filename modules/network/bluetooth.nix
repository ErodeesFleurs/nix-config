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

    enable-manager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install a GUI Bluetooth manager (overskride)";
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

    # 蓝牙管理 GUI：overskride（GTK4，替代 GTK3 时代的 blueman）
    environment.systemPackages =
      with pkgs;
      lib.mkIf cfg.enable-manager [
        bluez
        bluez-tools
        overskride
      ];
  };
}
