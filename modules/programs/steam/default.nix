{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.programs.steam;
in
{
  options.modules.programs.steam = {
    enable = lib.mkEnableOption "Steam gaming platform";

    remotePlay = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Steam Remote Play";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Remote Play";
      };
    };

    dedicatedServer = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Steam dedicated server support";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for dedicated servers";
      };
    };

    extest = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Steam input emulation (extest)";
    };

    gamescopeSession = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Gamescope session for Steam";
    };

    protontricks = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Protontricks for managing Proton prefixes";
    };

    extraCompatPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional compatibility packages for Steam";
      example = lib.literalExpression "[ pkgs.proton-ge-bin ]";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;

      remotePlay = {
        openFirewall = cfg.remotePlay.enable && cfg.remotePlay.openFirewall;
      };

      dedicatedServer = {
        openFirewall = cfg.dedicatedServer.enable && cfg.dedicatedServer.openFirewall;
      };

      extest = {
        enable = cfg.extest;
      };

      gamescopeSession = {
        enable = cfg.gamescopeSession;
      };

      protontricks = {
        enable = cfg.protontricks;
      };

      extraCompatPackages = cfg.extraCompatPackages;
    };
  };
}
