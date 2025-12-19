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

    listen-address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The address V2Ray listens on";
    };

    port = mkOption {
      type = types.port;
      default = 1080;
      description = "The port V2Ray listens on";
    };

    enable-v2raya = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable V2RayA GUI";
    };

    enable-udp = mkOption {
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
            listen = cfg.listen-address;
            port = cfg.port;
            protocol = cfg.protocol;
            settings = {
              udp = cfg.enable-udp;
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

    services.v2raya.enable = cfg.enable-v2raya;
  };
}
