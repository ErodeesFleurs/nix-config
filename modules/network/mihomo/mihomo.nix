{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.network.mihomo;
  configPath = config.age.secrets."config.mihomo.yaml".path;
in
{
  options.modules.network.mihomo = {
    enable = lib.mkEnableOption "Mihomo proxy service";

    config-file = lib.mkOption {
      type = lib.types.path;
      default = configPath;
      description = "Mihomo YAML configuration file";
    };

    socks-port = lib.mkOption {
      type = lib.types.port;
      default = 7891;
      readOnly = true;
      description = "Local Mihomo SOCKS5 port used by dae (fixed: the dae config points to it)";
    };

    webui = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the local MetaCubeXD Web UI";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mihomo = {
      enable = true;
      package = pkgs.mihomo;
      configFile = cfg.config-file;
      tunMode = false;
      webui = if cfg.webui then pkgs.metacubexd else null;
    };

    # 等待真实外网连通再启动代理栈：mihomo 启动时拉取订阅（kycloud provider）、
    # dae 按默认路由确定 wan 接口，二者失败后都不自愈。
    # 注意 network-online.target 不可靠：NM-wait-online 在 iwd 后端下，
    # 若 WiFi 固件未就绪时启动会立即通过（无设备可等），不代表真实连通。
    # 45 秒超时后 mihomo/dae 仍会启动（离线场景的优雅降级）。
    systemd.services.proxy-net-wait = {
      description = "Wait for internet connectivity before starting the proxy stack";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = 45;
      };
      path = [ pkgs.curl ];
      script = ''
        until curl -fs --max-time 3 -o /dev/null http://cp.cloudflare.com; do
          sleep 1
        done
      '';
    };

    systemd.services.mihomo = {
      wants = [ "proxy-net-wait.service" ];
      after = [ "proxy-net-wait.service" ];
    };

    systemd.services.dae = {
      wants = [
        "mihomo.service"
        "proxy-net-wait.service"
      ];
      after = [
        "mihomo.service"
        "proxy-net-wait.service"
      ];
    };
  };
}
