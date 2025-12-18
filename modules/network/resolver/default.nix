{ config, lib, ... }:

/*
  nix-config/modules/network/resolver/default.nix
  Networking toggles submodule — 网络开关子模块

  CN:
  本子模块提供若干常见的网络服务开关（例如 systemd-resolved 与传统 resolvconf）的声明式选项。
  这些选项由新命名空间 `modules.network.resolver` 的启用开关控制（即仅在 `modules.network.resolver.enable = true` 时生效）。
  模块不会强行改变其它网络服务（例如 NetworkManager）的行为，而是把可变性与冲突检测留给用户配置。

  EN:
  This submodule exposes commonly used networking toggles (e.g. systemd-resolved vs resolvconf).
  Options are controlled by the `modules.network.resolver` enable switch and are intended to provide
  a simple, declarative way to choose resolver-related behavior without overriding unrelated networking services.
*/

let
  cfg = config.modules.network.resolver;
in
{
  options.modules.network.resolver = {
    enable = lib.mkEnableOption "Networking convenience toggles / 网络开关";

    enableResolved = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable systemd-resolved service.
        CN: 启用 systemd-resolved（DNS 解析服务）。开启后通常不需要传统的 resolvconf。
        EN: Enable the systemd-resolved resolver service. When true, you typically do not need classic resolvconf.
      '';
    };

    enableResolvconf = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable the traditional resolvconf integration (networking.resolvconf).
        CN: 启用传统的 resolvconf（用于某些工具/场景需要把 /etc/resolv.conf 管理为常规文件的情况）。
        EN: Enable the classic resolvconf mechanism. Useful for setups that rely on `networking.resolvconf`.
      '';
    };

    # Expose a small helper option to prefer a specific resolver mode; this simply sets the two booleans
    # for convenience. It does not add extra logic beyond setting the booleans; users may still override individually.
    preferResolved = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = ''
        Convenience option: when true prefer systemd-resolved; when false prefer resolvconf.
        CN: 便捷开关：true 时偏好 systemd-resolved，false 时偏好 resolvconf。为 null 则不改变各自选项。
        EN: Convenience helper: true prefers systemd-resolved, false prefers resolvconf. Null leaves explicit flags unchanged.
      '';
    };
  };

  # Implementation: apply only when this resolver submodule is enabled.
  config = lib.mkIf cfg.enable (
    let
      # Evaluate final booleans:
      # - if preferResolved == true -> resolved = true, resolvconf = false
      # - if preferResolved == false -> resolved = false, resolvconf = true
      # - if preferResolved == null -> use explicit enableResolved / enableResolvconf options
      finalResolved =
        if cfg.preferResolved == true then
          true
        else if cfg.preferResolved == false then
          false
        else
          cfg.enableResolved;
      finalResolvconf =
        if cfg.preferResolved == false then
          true
        else if cfg.preferResolved == true then
          false
        else
          cfg.enableResolvconf;
    in
    {
      services.resolved.enable = finalResolved;
      networking.resolvconf.enable = finalResolvconf;

      # Warn user if they enabled both resolvers which is usually a misconfiguration.
      warnings = lib.optionalString (finalResolved && finalResolvconf) ''
        CN: systemd-resolved 与 networking.resolvconf 同时启用可能会引发冲突（例如 /etc/resolv.conf 的归属问题）。
        EN: Enabling both systemd-resolved and networking.resolvconf may conflict (ownership/format of /etc/resolv.conf).
      '';
    }
  );
}
