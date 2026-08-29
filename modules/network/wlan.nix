{
  config,
  lib,
  pkgs,
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

    # 一次性迁移：把 NM 保存的 WiFi 凭据转换为 iwd 网络文件
    # （/var/lib/iwd 已随 /var 持久化；已存在的网络跳过；仅 WPA-PSK，
    # 企业网/隐藏网络需手动重建。全部迁移完成后此服务可删）
    systemd.services.iwd-import-nm-connections = {
      description = "Import WiFi credentials from NetworkManager into iwd";
      wantedBy = [ "iwd.service" ];
      before = [ "iwd.service" ];
      unitConfig.ConditionPathExists = "/persist/etc/NetworkManager/system-connections";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script =
        let
          # 注意不用 writers.writePython3：它附带 flake8 检查，样式问题会直接构建失败
          importer = pkgs.writeText "iwd-import-nm.py" ''
            import configparser
            import pathlib

            SRC = pathlib.Path("/persist/etc/NetworkManager/system-connections")
            DST = pathlib.Path("/var/lib/iwd")

            SAFE = frozenset(
                b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 _.-"
            )

            def iwd_name(ssid: str) -> str:
                # iwd 文件名：不安全字符按 =XX（UTF-8 字节十六进制）编码
                out = []
                for b in ssid.encode("utf-8"):
                    out.append(chr(b) if b in SAFE else f"={b:02X}")
                return "".join(out) + ".psk"

            imported = skipped = 0
            for f in sorted(SRC.glob("*.nmconnection")):
                cp = configparser.ConfigParser(strict=False)
                cp.optionxform = str
                try:
                    cp.read(f)
                except configparser.Error:
                    continue
                if not cp.has_section("wifi") or not cp.has_section("wifi-security"):
                    continue
                ssid = cp["wifi"].get("ssid")
                psk = cp["wifi-security"].get("psk")
                if not ssid or not psk:
                    continue
                out = DST / iwd_name(ssid)
                if out.exists():
                    skipped += 1
                    continue
                if len(psk) == 64 and all(c in "0123456789abcdefABCDEF" for c in psk):
                    body = f"[Security]\nPreSharedKey={psk}\n"
                else:
                    body = f"[Security]\nPassphrase={psk}\n"
                out.write_text(body)
                out.chmod(0o600)
                imported += 1

            print(f"iwd-import-nm: {imported} imported, {skipped} skipped")
          '';
        in
        ''
          ${pkgs.python3}/bin/python3 ${importer}
        '';
    };
  };
}
