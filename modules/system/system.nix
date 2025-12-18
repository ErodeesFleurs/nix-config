{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.system;
in
{
  options.modules.system = {
    enable = lib.mkEnableOption "System base configuration";

    trustedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "fleurs" ];
      description = "List of trusted Nix users";
    };

    autoOptimise = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically optimize the Nix store";
    };

    autoGC = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically run garbage collection";
    };

    gcOptions = lib.mkOption {
      type = lib.types.str;
      default = "--delete-older-than 7d";
      description = "Options for garbage collection";
    };

    allowUnfree = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow unfree packages";
    };

    permittedInsecurePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of permitted insecure packages";
      example = [ "openssl-1.0.2u" ];
    };

    substituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "https://cache.nixos.org" ];
      description = "List of binary cache substituters";
    };

    trustedPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of trusted public keys for substituters";
    };

    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "26.05";
      description = "NixOS state version";
    };

    enableInit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable nixos-init";
    };

    overlayMutable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Make /etc overlay mutable";
    };

    machineId = lib.mkOption {
      type = lib.types.str;
      default = builtins.hashString "md5" (config.networking.hostName or "unknown") + "\n";
      description = "Set a fixed machine ID for the system";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nix 系统设置
    nix = {
      settings = {
        experimental-features = [
          "flakes"
          "nix-command"
        ];
        trusted-users = cfg.trustedUsers;
        substituters = cfg.substituters;
        trusted-public-keys = cfg.trustedPublicKeys;
      };

      optimise = {
        automatic = cfg.autoOptimise;
      };

      gc = lib.mkIf cfg.autoGC {
        automatic = true;
        dates = "weekly";
        options = cfg.gcOptions;
      };
    };

    # 系统配置
    system = {
      stateVersion = cfg.stateVersion;
      nixos-init.enable = cfg.enableInit;
      etc.overlay = {
        enable = true;
        mutable = cfg.overlayMutable;
      };
    };

    environment = lib.mkIf (!cfg.overlayMutable) {
      etc = {
        "machine-id".text = cfg.machineId;
        "NetworkManager/system-connections/.keep".text = "";
        "v2raya/.keep".text = "";
      };
    };

    fileSystems."/etc/NetworkManager/system-connections" = {
      device = "/persist/etc/NetworkManager/system-connections";
      options = [
        "bind"
        "rw"
      ];
      noCheck = true;
    };

    fileSystems."/etc/v2raya" = {
      device = "/persist/etc/v2raya";
      options = [
        "bind"
        "rw"
      ];
      noCheck = true;
    };

    systemd.tmpfiles.rules = [
      "d /persist/etc/NetworkManager/system-connections 0700 root root -"
      "d /persist/var/lib/nixos 0755 root root -"
      "d /persist/etc/v2raya 0750 root root -"
    ];

    services.resolved.enable = false;
    networking.resolvconf.enable = false;
    services.dnsproxy = {
      enable = true;
      flags = [
        "--cache"
        "--cache-optimistic"
        "--edns"
      ];
      settings = {
        bootstrap = [
          "8.8.8.8"
          "127.2.0.17"
          "119.29.29.29"
          "114.114.114.114"
          "223.6.6.6"
        ];
        listen-addrs = [ "::" ];
        listen-ports = [ 53 ];
        upstream-mode = "parallel";
        upstream = [
          "tls://1.1.1.1"
          "quic://dns.alidns.com"
          "h3://dns.alidns.com/dns-query"
          "tls://dot.pub"
          "https://doh.pub/dns-query"
        ];
      };
    };
  };
}
