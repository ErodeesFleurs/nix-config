{ config, lib, ... }:
let
  cfg = config.modules.network.dns;
in
{
  options.modules.network.dns = {
    enable = lib.mkEnableOption "DNS proxy configuration / DNS 代理配置";

    # Use a distinct name for the runtime service toggle to avoid colliding with mkEnableOption.
    enableService = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        启用 dnsproxy 服务。
      '';
    };

    flags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "--cache"
        "--cache-optimistic"
        "--edns"
      ];
      description = ''
        传递给 dnsproxy 可执行文件的命令行参数列表（例如缓存与 EDNS 选项）。
      '';
      example = [
        "--cache"
        "--edns"
      ];
    };

    bootstrap = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "8.8.8.8"
        "127.2.0.17"
        "119.29.29.29"
        "114.114.114.114"
        "223.6.6.6"
      ];
      description = ''
        dnsproxy 用于引导的上游 IP 列表（用于初始化上游解析器列表）。
      '';
    };

    listenAddrs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "::" ];
      description = ''
        dnsproxy 监听的地址列表（IPv4/IPv6 地址或通配符）。
      '';
    };

    listenPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ 53 ];
      description = ''
        dnsproxy 监听的端口号列表（通常为 53）。
      '';
    };

    upstreamMode = lib.mkOption {
      type = lib.types.str;
      default = "parallel";
      description = ''
        dnsproxy 的上游查询模式（例如 parallel、sequential 等，具体依赖 dnsproxy 版本）。
      '';
      example = "parallel";
    };

    upstream = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "tls://1.1.1.1"
        "quic://dns.alidns.com"
        "h3://dns.alidns.com/dns-query"
        "tls://dot.pub"
        "https://doh.pub/dns-query"
      ];
      description = ''
        dnsproxy 使用的上游解析器 URI 列表（例如 tls://、https://、quic:// 等）。
      '';
    };
  };

  # Apply the service configuration only when this dns module is enabled.
  config = lib.mkIf cfg.enable (
    lib.mkIf cfg.enableService {
      services.dnsproxy = {
        enable = cfg.enableService;

        # Command-line flags
        flags = cfg.flags;

        # Nested settings passed to the service
        settings = {
          bootstrap = cfg.bootstrap;
          listen-addrs = cfg.listenAddrs;
          "listen-ports" = cfg.listenPorts;
          "upstream-mode" = cfg.upstreamMode;
          upstream = cfg.upstream;
        };
      };
    }
  );
}
