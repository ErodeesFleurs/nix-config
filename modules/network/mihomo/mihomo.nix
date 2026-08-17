{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.network.mihomo;
  configPath = config.age.secrets."config.mihomo.yaml".path;

  metacubexd = pkgs.stdenvNoCC.mkDerivation {
    pname = "metacubexd";
    version = "1.273.0";
    src = pkgs.fetchurl {
      url = "https://github.com/MetaCubeX/metacubexd/releases/download/v1.273.0/compressed-dist.tgz";
      hash = "sha256-B24F0uPcZkGg7CgapLl6GBk/vMN50Tl2LDLZCtsieTw=";
    };
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      tar -xzf $src -C $out
    '';
  };
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
      webui = if cfg.webui then metacubexd else null;
    };

    systemd.services.dae = {
      wants = [ "mihomo.service" ];
      after = [ "mihomo.service" ];
    };
  };
}
