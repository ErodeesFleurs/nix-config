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
        default = false;
        description = "Enable Dorion Discord client";
      };

      auto-clear-cache = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically clear cache on startup";
      };

      disable-hardware-accel = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Disable hardware acceleration";
      };

      rpc-server = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable RPC server";
      };

      rpc-process-scanner = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable RPC process scanner";
      };

      desktop-notifications = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable desktop notifications";
      };

      unread-badge = lib.mkOption {
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

      auto-update = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable automatic updates";
      };

      notify-about-updates = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Notify about available updates";
      };

      auto-update-notification = lib.mkOption {
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
        autoClearCache = cfg.dorion.auto-clear-cache;
        disableHardwareAccel = cfg.dorion.disable-hardware-accel;
        rpcServer = cfg.dorion.rpc-server;
        rpcProcessScanner = cfg.dorion.rpc-process-scanner;
        desktopNotifications = cfg.dorion.desktop-notifications;
        unreadBadge = cfg.dorion.unread-badge;
      };

      config = {
        frameless = cfg.config.frameless;
        autoUpdate = cfg.config.auto-update;
        notifyAboutUpdates = cfg.config.notify-about-updates;
        autoUpdateNotification = cfg.config.auto-update-notification;
        plugins = cfg.config.plugins;
      };
    };
  };
}
