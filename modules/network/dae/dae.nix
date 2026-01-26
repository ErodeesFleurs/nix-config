{
  config,
  lib,
  pkgs,
  age,
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

  config = lib.mkIf cfg.enable {

    services.dae = {
      enable = true;

      openFirewall = {
        enable = true;
        port = 12345;
      };
      assets = with pkgs; [
        v2ray-geoip
        v2ray-domain-list-community
      ];

      assetsPath = "/etc/dae";

      configFile = age.secrets.monitrc.file;
    };

    services.daed = {
      enable = true;

      openFirewall = {
        enable = true;
        port = 12345;
      };

      configDir = "/etc/daed";
    };

    systemd.tmpfiles.rules = lib.mkIf enable_persistent [
      "d /persist/etc/dae 0750 root root -"
      "d /persist/etc/daed 0750 root root -"
    ];

    environment = lib.mkIf enable_persistent {
      etc = {
        "dae/.keep".text = "";
        "daed/.keep".text = "";
      };
    };

    fileSystems = lib.mkIf enable_persistent {
      "/etc/dae" = {
        device = "/persist/etc/dae";
        options = [
          "bind"
          "rw"
        ];
        noCheck = true;
      };

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
