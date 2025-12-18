{
  config,
  lib,
  pkgs,
  ...
}:

/*
  nix-config/modules/programs/localsend/default.nix
  LocalSend program module — 本地传输服务 LocalSend

  CN:
  本模块将 LocalSend 的启用与防火墙选项暴露到 `modules.programs.localsend` 命名空间中。
  通过此声明式模块可以在主机配置中开启/关闭 LocalSend 服务并控制是否自动打开防火墙端口。
  EN:
  Exposes LocalSend toggles under `modules.programs.localsend`. Allows enabling the LocalSend service
  and controlling whether firewall ports should be opened automatically.
*/

let
  cfg = config.modules.programs.localsend;
in
{
  options.modules.programs.localsend = {
    enable = lib.mkEnableOption "LocalSend service / 本地传输服务";

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to automatically open firewall ports for LocalSend.
        CN: 是否自动为 LocalSend 打开防火墙端口（便于接收连接）。
        EN: Whether to automatically open firewall ports to allow LocalSend connections.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.localsend = {
      enable = true;
      openFirewall = cfg.openFirewall;
    };

    # Ensure the LocalSend package is available when enabled (optional; relies on pkgs)
    environment.systemPackages = lib.mkIf cfg.enable [
      pkgs.localsend
    ];
  };
}
