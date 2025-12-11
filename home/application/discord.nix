{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.discord;
in
{
  options.homeModules.discord = {
    enable = lib.mkEnableOption "Nixcord (Discord client with Vencord)";

    vesktop = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Vesktop Discord client";
      };
    };

    dorion = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Dorion Discord client";
      };

      autoClearCache = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically clear cache on startup";
      };

      disableHardwareAccel = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Disable hardware acceleration";
      };

      rpcServer = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable RPC server";
      };

      rpcProcessScanner = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable RPC process scanner";
      };

      desktopNotifications = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable desktop notifications";
      };

      unreadBadge = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show unread badge";
      };
    };

    config = {
      frameless = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use frameless window";
      };

      autoUpdate = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable automatic updates";
      };

      notifyAboutUpdates = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Notify about available updates";
      };

      autoUpdateNotification = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Show auto-update notifications";
      };

      plugins = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Vencord plugins configuration";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nixcord = {
      enable = true;

      vesktop.enable = cfg.vesktop.enable;

      dorion = {
        enable = cfg.dorion.enable;
        autoClearCache = cfg.dorion.autoClearCache;
        disableHardwareAccel = cfg.dorion.disableHardwareAccel;
        rpcServer = cfg.dorion.rpcServer;
        rpcProcessScanner = cfg.dorion.rpcProcessScanner;
        desktopNotifications = cfg.dorion.desktopNotifications;
        unreadBadge = cfg.dorion.unreadBadge;
      };

      config = {
        frameless = cfg.config.frameless;
        autoUpdate = cfg.config.autoUpdate;
        notifyAboutUpdates = cfg.config.notifyAboutUpdates;
        autoUpdateNotification = cfg.config.autoUpdateNotification;
        plugins = cfg.config.plugins;
      };
    };
  };
}
