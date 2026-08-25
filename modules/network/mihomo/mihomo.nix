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
      description = "Local Mihomo SOCKS5 port used by dae";
    };

    webui = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the local MetaCubeXD Web UI";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.socks-port == 7891;
        message = "modules.network.mihomo.socks-port must remain 7891 because the dae config points to it.";
      }
    ];

    services.mihomo = {
      enable = true;
      package = pkgs.mihomo;
      configFile = cfg.config-file;
      tunMode = false;
      webui = if cfg.webui then pkgs.metacubexd else null;
    };

    systemd.services.dae = {
      wants = [ "mihomo.service" ];
      after = [ "mihomo.service" ];
    };
  };
}
