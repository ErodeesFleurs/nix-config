{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.network.wlan;
in
{
  options.modules.network.wlan = {
    enable = mkEnableOption "Wireless LAN and NetworkManager support";

    host-name = mkOption {
      type = types.str;
      default = "nixos";
      description = "The hostName of the system";
    };

    enable-nm-applet = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable nm-applet tray icon";
    };

    show-indicator = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to show network indicator in nm-applet";
    };

    allowed-tcp-ports = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "List of allowed TCP ports through the firewall";
      example = [
        5900
        5901
      ];
    };

    allowed-udp-ports = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "List of allowed UDP ports through the firewall";
      example = [
        53
        67
      ];
    };

    enable-firewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the firewall";
    };
  };

  config = mkIf cfg.enable {
    networking = {
      hostName = cfg.host-name;
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };

      firewall = mkIf cfg.enable-firewall {
        enable = true;
        allowedTCPPorts = cfg.allowed-tcp-ports;
        allowedUDPPorts = cfg.allowed-udp-ports;
      };
    };

    # 启用 WiFi 托盘图标
    programs.nm-applet = mkIf cfg.enable-nm-applet {
      enable = true;
      indicator = cfg.show-indicator;
    };

    # 添加网络管理相关工具
    environment.systemPackages = with pkgs; [
      networkmanagerapplet
    ];
  };
}
