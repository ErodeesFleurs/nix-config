{ config, lib, ... }:
let
  cfg = config.modules.network.resolver;
  dnsCfg = config.modules.network.dns;
  useDnsproxy = dnsCfg.enable or false;

  # Evaluate final booleans:
  # - if preferResolved == true -> resolved = true, resolvconf = false
  # - if preferResolved == false -> resolved = false, resolvconf = true
  # - if preferResolved == null -> use explicit enableResolved / enableResolvconf options
  finalResolved =
    if cfg.prefer-resolved == true then
      true
    else if cfg.prefer-resolved == false then
      false
    else
      cfg.enable-resolved;
  finalResolvconf =
    if cfg.prefer-resolved == false then
      true
    else if cfg.prefer-resolved == true then
      false
    else
      cfg.enable-resolvconf;

  dnsproxyLoopback =
    useDnsproxy && lib.elem "127.0.0.1" (config.services.dnsproxy.settings.listen-addrs or [ ]);
in
{
  options.modules.network.resolver = {
    enable = lib.mkEnableOption "网络开关";

    enable-resolved = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        启用 systemd-resolved（DNS 解析服务）。开启后通常不需要传统的 resolvconf。
      '';
    };

    enable-resolvconf = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        启用传统的 resolvconf（用于某些工具/场景需要把 /etc/resolv.conf 管理为常规文件的情况）。
      '';
    };

    # Expose a small helper option to prefer a specific resolver mode; this simply sets the two booleans
    # for convenience. It does not add extra logic beyond setting the booleans; users may still override individually.
    prefer-resolved = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = ''
        便捷开关：true 时偏好 systemd-resolved，false 时偏好 resolvconf。为 null 则不改变各自选项。
      '';
    };
  };

  # Implementation: apply only when this resolver submodule is enabled.
  config = lib.mkIf cfg.enable {
    services.resolved = {
      enable = finalResolved;
      settings.Resolve = lib.mkMerge [
        (lib.mkIf finalResolved {
          # 关闭 mDNS/LLMNR（原 NetworkManager connectionConfig 的对应项）
          LLMNR = false;
          MulticastDNS = false;
        })
        (lib.mkIf (finalResolved && useDnsproxy) {
          DNS = [ "127.0.0.1" ];
          FallbackDNS = [
            "1.1.1.1"
            "8.8.8.8"
            "119.29.29.29"
          ];
          DNSStubListener = true;
        })
      ];
    };
    networking.resolvconf.enable = finalResolvconf;

    # resolved 以 dnsproxy 为上游（见上方 DNS = 127.0.0.1），require 保证联动拉起。
    # 注意：不要在此加 after = [ "dnsproxy.service" ]——它会构成
    # iwd → network.target → dnsproxy → resolved → sysinit → iwd 的排序环，
    # systemd 打破环时可能随机删除 iwd/resolved/nss-lookup 的启动任务（曾导致 WiFi 无法连接）。
    # 启动顺序在此无功能需求：dnsproxy 仅在响应查询时才需要 resolved（bootstrap）。
    systemd.services.systemd-resolved = lib.mkIf (finalResolved && useDnsproxy) {
      requires = [ "dnsproxy.service" ];
    };

    # Warn user if they enabled both resolvers which is usually a misconfiguration.
    # The NixOS `warnings` option expects a list of strings; produce a list when the condition holds.
    warnings = lib.optional (finalResolved && finalResolvconf) [
      "systemd-resolved 与 networking.resolvconf 同时启用可能会引发冲突（例如 /etc/resolv.conf 的归属问题）。"
    ];

    assertions = lib.optionals (finalResolved && useDnsproxy) [
      {
        assertion = dnsproxyLoopback;
        message = ''
          modules.network.dns 启用且 systemd-resolved 作为前端时，dnsproxy 必须监听 127.0.0.1，
          这样 systemd-resolved 才能将其作为上游转发器。
          请在 modules.network.dns.listen-addrs 中加入 "127.0.0.1"。
        '';
      }
    ];
  };
}
