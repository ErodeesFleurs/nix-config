{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.network.wlan;
in
{
  options.modules.network.wlan = {
    enable = lib.mkEnableOption "Wireless LAN (iwd + systemd-networkd)";

    host-name = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "The hostName of the system";
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

      # 纯 iwd + systemd-networkd（取代 NetworkManager）：
      # iwd 负责 WiFi 关联/漫游，networkd 负责 DHCP/IPv6。
      # 网络管理用 iwctl 或 impala（TUI，见 home/system/packages.nix）。
      useNetworkd = true;
      # hardware-configuration.nix 中有 lib.mkDefault true，需显式关闭全局 DHCP
      useDHCP = false;
      wireless.iwd.enable = true;

      firewall = lib.mkIf cfg.enable-firewall {
        enable = true;
        allowedTCPPorts = cfg.allowed-tcp-ports;
        allowedUDPPorts = cfg.allowed-udp-ports;
      };
    };

    systemd.network.networks = {
      "10-wired" = {
        matchConfig.Name = [
          "en*"
          "eth*"
        ];
        networkConfig = {
          DHCP = "yes";
          IPv6PrivacyExtensions = "kernel";
        };
        # 笔记本有线口常年不插线：不参与 network-online 判定，
        # 否则 wait-online 每次 switch/开机都在 no-carrier 上等 120s 超时
        linkConfig.RequiredForOnline = "no";
        dhcpV4Config.RouteMetric = 100;
        ipv6AcceptRAConfig.RouteMetric = 100;
      };
      "20-wlan" = {
        matchConfig.Name = "wlan*";
        networkConfig = {
          DHCP = "yes";
          # 交由 networking.tempAddresses 设置的 sysctl 决定，networkd 不覆写
          IPv6PrivacyExtensions = "kernel";
        };
        dhcpV4Config.RouteMetric = 600;
        ipv6AcceptRAConfig.RouteMetric = 600;
      };
    };

    # NM→iwd 凭据迁移已在两台主机完成并验证（2026-08）；
    # 迁移服务与 /persist/etc/NetworkManager 均已移除。
  };
}
