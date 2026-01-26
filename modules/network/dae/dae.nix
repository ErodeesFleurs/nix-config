{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.network.dae;
  enable_persistent = !config.modules.etc.overlay-mutable;
in
{
  options.modules.network.dae = {
    enable = lib.mkEnableOption "Dae support";
    enable-daed = lib.mkEnableOption "Daed support";
  };

  config = lib.mkIf (cfg.enable || cfg.enable-daed) {

    services.dae = {
      enable = cfg.enable;

      package = pkgs.dae;

      openFirewall = {
        enable = true;
        port = 12345;
      };
      assets = with pkgs; [
        v2ray-geoip
        v2ray-domain-list-community
      ];

      configFile = config.age.secrets."config.dae".path;
    };

    services.daed = {
      enable = cfg.enable-daed;

      package = pkgs.daed;

      openFirewall = {
        enable = true;
        port = 12345;
      };

      listen = "127.0.0.1:2023";

      configDir = "/etc/daed";
    };

    systemd.tmpfiles.rules = lib.mkIf enable_persistent [
      "d /persist/etc/daed 0750 root root -"
    ];

    environment = lib.mkIf enable_persistent {
      etc = {
        "daed/.keep".text = "";
      };
    };

    fileSystems = lib.mkIf enable_persistent {
      "/etc/daed" = {
        device = "/persist/etc/daed";
        options = [
          "bind"
          "rw"
        ];
        noCheck = true;
      };
    };
  };
}
