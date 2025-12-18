{ config, lib, ... }:

/*
  nix-config/modules/network/dns/default.nix
  DNS proxy (dnsproxy) submodule

  CN:
  本子模块提供对 `services.dnsproxy` 的声明式配置接口，并把其与新命名空间 `modules.network.dns`
  的启用开关结合起来。模块定义了可配置项（启用开关、命令行 flags 与内层 settings），
  并在该命名空间启用时应用这些配置。注释为中英双语，便于协作开发与维护。

  EN:
  Provides a declarative interface for the `services.dnsproxy` configuration and integrates it with the
  `modules.network.dns` namespace. This submodule exposes options for enabling dnsproxy,
  configuring CLI flags and nested `settings` (bootstrap servers, listen addresses/ports and upstreams).
*/

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
        Enable dnsproxy service.
        CN: 启用 dnsproxy 服务。
        EN: Toggle dnsproxy service on or off.
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
        Command-line flags passed to the dnsproxy binary.
        CN: 传递给 dnsproxy 可执行文件的命令行参数列表（例如缓存与 EDNS 选项）。
        EN: CLI flags for dnsproxy (e.g. enable cache and EDNS).
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
        Bootstrap upstream IPs used by dnsproxy to resolve initial upstreams.
        CN: dnsproxy 用于引导的上游 IP 列表（用于初始化上游解析器列表）。
        EN: IP addresses used for bootstrap/resolver discovery by dnsproxy.
      '';
    };

    listenAddrs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "::" ];
      description = ''
        Addresses dnsproxy listens on.
        CN: dnsproxy 监听的地址列表（IPv4/IPv6 地址或通配符）。
        EN: Listen addresses for dnsproxy.
      '';
    };

    listenPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ 53 ];
      description = ''
        Ports dnsproxy listens on.
        CN: dnsproxy 监听的端口号列表（通常为 53）。
        EN: Listen ports for dnsproxy (typically 53).
      '';
    };

    upstreamMode = lib.mkOption {
      type = lib.types.str;
      default = "parallel";
      description = ''
        Upstream mode for dnsproxy (how it queries upstreams).
        CN: dnsproxy 的上游查询模式（例如 parallel、sequential 等，具体依赖 dnsproxy 版本）。
        EN: Upstream query mode (e.g. \"parallel\"). Check dnsproxy docs for supported modes.
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
        Upstream resolvers used by dnsproxy (URIs).
        CN: dnsproxy 使用的上游解析器 URI 列表（例如 tls://、https://、quic:// 等）。
        EN: Upstream DNS resolver URIs (e.g. TLS/HTTPS/QUIC-based resolvers).
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
          "listen-addrs" = cfg.listenAddrs;
          "listen-ports" = cfg.listenPorts;
          "upstream-mode" = cfg.upstreamMode;
          upstream = cfg.upstream;
        };
      };
    }
  );
}
