{ config, lib, ... }:
let
  cfg = config.modules.network.resolver;
in
{
  options.modules.network.resolver = {
    enable = lib.mkEnableOption "网络开关";

    enableResolved = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        启用 systemd-resolved（DNS 解析服务）。开启后通常不需要传统的 resolvconf。
      '';
    };

    enableResolvconf = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        启用传统的 resolvconf（用于某些工具/场景需要把 /etc/resolv.conf 管理为常规文件的情况）。
      '';
    };

    # Expose a small helper option to prefer a specific resolver mode; this simply sets the two booleans
    # for convenience. It does not add extra logic beyond setting the booleans; users may still override individually.
    preferResolved = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = ''
        便捷开关：true 时偏好 systemd-resolved，false 时偏好 resolvconf。为 null 则不改变各自选项。
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
      # The NixOS `warnings` option expects a list of strings; produce a list when the condition holds.
      warnings = lib.optional (finalResolved && finalResolvconf) [
        "systemd-resolved 与 networking.resolvconf 同时启用可能会引发冲突（例如 /etc/resolv.conf 的归属问题）。"
      ];
    }
  );
}
