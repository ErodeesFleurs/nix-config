{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.modules.network.dae;
  enable_persistent = !config.modules.etc.overlay-mutable;

  # Render a list of domain rules as dae domain(suffix: ...) directives.
  renderDomainRules =
    indent: domains: action:
    lib.concatMapStringsSep "\n" (d: "${indent}domain(suffix: ${d}) -> ${action}") domains;

  # DNS request 段的域名匹配器是 qname()；domain() 只在 traffic 路由段合法，
  # 否则 dae 启动即 FATAL unknown function: domain
  renderQnameSuffixRules =
    indent: domains: action:
    lib.concatMapStringsSep "\n" (d: "${indent}qname(suffix: ${d}) -> ${action}") domains;

  # Render a list of geosite rules.
  renderGeositeRules =
    indent: sites: action:
    lib.concatMapStringsSep "\n" (s: "${indent}domain(geosite:${s}) -> ${action}") sites;

  configText = pkgs.writeText "config.dae" ''
        global {
            tproxy_port: ${toString cfg.tproxy-port}
            tproxy_port_protect: true
            pprof_port: 0
            so_mark_from_dae: 0
            log_level: info

            lan_interface: ${cfg.lan-interface}
            wan_interface: ${cfg.wan-interface}

            disable_waiting_network: true
            enable_local_tcp_fast_redirect: false
            auto_config_kernel_parameter: true

            tcp_check_url: '${cfg.tcp-check-url}'
            tcp_check_http_method: HEAD
            udp_check_dns: '${cfg.udp-check-dns}'
            check_interval: 30s
            check_tolerance: 500ms

            dial_mode: ${cfg.dial-mode}
            allow_insecure: false
            sniffing_timeout: 100ms

            utls_imitate: chrome_auto
            tls_implementation: tls
            mptcp: false
        }

        node {
            mihomo: '${cfg.proxy-upstream}'
        }

        group {
            proxy {
                policy: fixed(0)
                filter: name(mihomo)
            }
        }

        dns {
            upstream {
                googledns: 'tcp+udp://dns.google:53'
                alidns: 'udp://dns.alidns.com:53'
            }
            routing {
                request {
    ${renderQnameSuffixRules "                " cfg.subscription-domains "alidns"}
                    qname(geosite:cn) -> alidns
                    fallback: googledns
                }
            }
        }

        routing {
            # Mihomo must bypass dae to prevent a proxy loop.
            pname(mihomo) -> must_direct

            pname(systemd-networkd) -> direct
            dip(224.0.0.0/3, 'ff00::/8') -> direct
            dscp(4) -> direct
            dip(geoip:private) -> direct

    ${renderDomainRules "        " cfg.subscription-domains "direct"}

    ${renderGeositeRules "        " cfg.proxy-geosites "proxy"}
    ${renderGeositeRules "        " cfg.direct-geosites "direct"}

            l4proto(udp) && dport(443) -> block
            dip(geoip:cn) -> direct

            fallback: proxy
        }
  '';
in
{
  options.modules.network.dae = {
    enable = lib.mkEnableOption "Dae support";
    enable-daed = lib.mkEnableOption "Daed support";

    tproxy-port = lib.mkOption {
      type = lib.types.port;
      default = 12345;
      description = "Transparent proxy port used by dae.";
    };

    lan-interface = lib.mkOption {
      type = lib.types.str;
      default = "virbr0";
      description = "LAN interface for dae.";
    };

    wan-interface = lib.mkOption {
      type = lib.types.str;
      default = "auto";
      description = "WAN interface for dae.";
    };

    dial-mode = lib.mkOption {
      type = lib.types.enum [
        "domain"
        "ip"
        "domain+ip"
      ];
      default = "domain";
      description = "Dae dial mode.";
    };

    proxy-upstream = lib.mkOption {
      type = lib.types.str;
      default = "socks5://127.0.0.1:7891";
      description = ''
        Upstream proxy URI used by dae (e.g., mihomo SOCKS5 endpoint).
        The default points to the local mihomo instance.
      '';
    };

    tcp-check-url = lib.mkOption {
      type = lib.types.str;
      default = "http://cp.cloudflare.com,1.1.1.1,2606:4700:4700::1111";
      description = "URL/IP list used by dae for TCP connectivity checks.";
    };

    udp-check-dns = lib.mkOption {
      type = lib.types.str;
      default = "dns.google.com:53,8.8.8.8,2001:4860:4860::8888";
      description = "DNS list used by dae for UDP connectivity checks.";
    };

    subscription-domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Domains that should bypass the proxy and resolve/return directly.
        Typically used for proxy subscription domains.
      '';
    };

    proxy-geosites = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "openai"
        "github"
        "docker"
        "geolocation-!cn"
      ];
      description = "Geosite categories that should be routed through the proxy.";
    };

    direct-geosites = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "apple@cn"
        "steam@cn"
        "tencent"
        "cn"
      ];
      description = "Geosite categories that should bypass the proxy.";
    };
  };

  config = lib.mkIf (cfg.enable || cfg.enable-daed) {

    services.dae = {
      inherit (cfg) enable;

      package = inputs.daeuniverse.packages.${pkgs.stdenv.hostPlatform.system}.dae-unstable;

      openFirewall = {
        enable = true;
        port = cfg.tproxy-port;
      };
      assets = with pkgs; [
        v2ray-rules-dat
      ];

      configFile = "/etc/dae/config.dae";
    };

    # daeuniverse 模块用 reloadTriggers 让 dae 热重载配置，但 `dae reload`
    # 不应用路由规则变更（实测：reload 成功后新增的直连规则仍走代理）。
    # 改为配置变更即重启（切换瞬间重建 eBPF 链路，秒级抖动）
    systemd.services.dae = {
      reloadTriggers = lib.mkForce [ ];
      restartTriggers = [ config.environment.etc."dae/config.dae".source ];
    };

    services.daed = {
      enable = cfg.enable-daed;

      package = pkgs.daed;

      openFirewall = {
        enable = true;
        port = cfg.tproxy-port;
      };

      listen = "127.0.0.1:2023";

      configDir = "/etc/daed";
    };

    systemd.tmpfiles.rules = lib.mkIf enable_persistent [
      "d /persist/etc/daed 0750 root root -"
    ];

    environment.etc = {
      "dae/config.dae" = {
        source = configText;
        mode = "0600";
      };
    }
    // lib.optionalAttrs enable_persistent {
      "daed/.keep".text = "";
    };

    fileSystems = lib.mkIf enable_persistent {
      "/etc/daed" = {
        device = "/persist/etc/daed";
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
