# 公共网络配置，被 spectre 与 spectre-surface 共享。
{ lib, ... }:

{
  modules.network = {
    wlan = {
      enable = true;
      enable-firewall = true;
    };

    bluetooth = {
      enable = true;
      enable-manager = true;
      power-on-boot = true;
    };

    ssh = {
      enable = true;
      enable-server = false;
      enable-agent = false;
      known-hosts = {
        "github.com".publicKey =
          "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
    };

    dns = {
      enable = true;
      enable-service = true;
      listen-addrs = [ "127.0.0.1" ];
      bootstrap = [
        "127.2.0.17"
        "8.8.8.8"
        "119.29.29.29"
        "114.114.114.114"
        "223.6.6.6"
      ];
      upstream = [
        "tls://1.1.1.1"
        "quic://dns.alidns.com"
        "h3://dns.alidns.com/dns-query"
        "tls://dot.pub"
        "https://doh.pub/dns-query"
      ];
    };

    resolver = {
      enable = true;
      enable-resolved = true;
      enable-resolvconf = false;
    };

    dae = {
      enable = true;
      enable-daed = false;
      # geoclue 的 beacondb GeoIP 查询必须走直连：
      # 经代理出口会让 IP 定位解析到代理机房城市（日出日落随之偏移）
      subscription-domains = [
        "api.beacondb.net"
      ];
    };

    mihomo = {
      enable = true;
      webui = true;
    };
  };

  networking.enableIPv6 = true;
  networking.tempAddresses = "default";

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    # 增大连接跟踪表，防止高并发代理时 conntrack 满
    "net.netfilter.nf_conntrack_max" = lib.mkDefault 1048576;
  };

  programs.ssh.extraConfig = ''
    HashKnownHosts yes
    VerifyHostKeyDNS ask
  '';
}
