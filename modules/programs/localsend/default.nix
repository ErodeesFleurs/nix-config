{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.programs.localsend;
in
{
  options.modules.programs.localsend = {
    enable = lib.mkEnableOption "LocalSend service / 本地传输服务";

    open-firewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        是否自动为 LocalSend 打开防火墙端口（便于接收连接）。
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.localsend = {
      enable = true;
      openFirewall = cfg.open-firewall;
    };

    # Ensure the LocalSend package is available when enabled (optional; relies on pkgs)
    environment.systemPackages = lib.mkIf cfg.enable [
      pkgs.localsend
    ];
  };
}
