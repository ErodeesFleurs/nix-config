{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.network.v2ray;
in
{
  options.modules.network.v2ray = {
    enable = mkEnableOption "V2Ray proxy service";

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The address V2Ray listens on";
    };

    port = mkOption {
      type = types.port;
      default = 1080;
      description = "The port V2Ray listens on";
    };

    enableV2rayA = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable V2RayA GUI";
    };

    enableUDP = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable UDP support";
    };

    protocol = mkOption {
      type = types.enum [
        "socks"
        "http"
        "shadowsocks"
      ];
      default = "socks";
      description = "The inbound protocol type";
    };
  };

  config = mkIf cfg.enable {
    services.v2ray = {
      enable = true;
      config = {
        inbounds = [
          {
            listen = cfg.listenAddress;
            port = cfg.port;
            protocol = cfg.protocol;
            settings = {
              udp = cfg.enableUDP;
            };
          }
        ];
        outbounds = [
          {
            protocol = "freedom";
          }
        ];
      };
    };

    services.v2raya.enable = cfg.enableV2rayA;
  };
}
