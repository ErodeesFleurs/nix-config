{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.network.wlan;
  enable_persistent = !config.modules.etc.overlay-mutable;
in
{
  options.modules.network.wlan = {
    enable = lib.mkEnableOption "Wireless LAN and NetworkManager support";

    host-name = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "The hostName of the system";
    };

    enable-nm-applet = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable nm-applet tray icon";
    };

    show-indicator = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to show network indicator in nm-applet";
    };

    allowed-tcp-ports = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ ];
      description = "List of allowed TCP ports through the firewall";
      example = [
        5900
        5901
      ];
    };

    allowed-udp-ports = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ ];
      description = "List of allowed UDP ports through the firewall";
      example = [
        53
        67
      ];
    };

    enable-firewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable the firewall";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      hostName = cfg.host-name;
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };

      firewall = lib.mkIf cfg.enable-firewall {
        enable = true;
        allowedTCPPorts = cfg.allowed-tcp-ports;
        allowedUDPPorts = cfg.allowed-udp-ports;
      };
    };

    # 启用 WiFi 托盘图标
    programs.nm-applet = lib.mkIf cfg.enable-nm-applet {
      enable = true;
      indicator = cfg.show-indicator;
    };

    systemd.tmpfiles.rules = lib.mkIf enable_persistent [
      "d /persist/etc/NetworkManager/system-connections 0700 root root -"
    ];

    environment = lib.mkIf enable_persistent {
      etc = {
        "NetworkManager/system-connections/.keep".text = "";
      };
    };

    fileSystems = lib.mkIf enable_persistent {
      "/etc/NetworkManager/system-connections" = {
        device = "/persist/etc/NetworkManager/system-connections";
        fsType = "none";
        options = [
          "bind"
          "rw"
        ];
        noCheck = true;
      };
    };
  };
}
