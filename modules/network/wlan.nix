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

    hostName = mkOption {
      type = types.str;
      default = "nixos";
      description = "The hostname of the system";
    };

    enableNmApplet = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable nm-applet tray icon";
    };

    showIndicator = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to show network indicator in nm-applet";
    };

    allowedTCPPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "List of allowed TCP ports through the firewall";
      example = [
        5900
        5901
      ];
    };

    allowedUDPPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "List of allowed UDP ports through the firewall";
      example = [
        53
        67
      ];
    };

    enableFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the firewall";
    };
  };

  config = mkIf cfg.enable {
    networking = {
      hostName = cfg.hostName;
      networkmanager.enable = true;

      firewall = mkIf cfg.enableFirewall {
        enable = true;
        allowedTCPPorts = cfg.allowedTCPPorts;
        allowedUDPPorts = cfg.allowedUDPPorts;
      };
    };

    # 启用 WiFi 托盘图标
    programs.nm-applet = mkIf cfg.enableNmApplet {
      enable = true;
      indicator = cfg.showIndicator;
    };

    # 添加网络管理相关工具
    environment.systemPackages = with pkgs; [
      networkmanagerapplet
    ];
  };
}
