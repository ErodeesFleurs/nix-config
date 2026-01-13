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

    remote-play = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Steam Remote Play";
      };

      open-firewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Remote Play";
      };
    };

    dedicated-server = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Steam dedicated server support";
      };

      open-firewall = lib.mkOption {
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

    gamescope-session = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Gamescope session for Steam";
    };

    protontricks = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Protontricks for managing Proton prefixes";
    };

    extra-compat-packages = lib.mkOption {
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
        openFirewall = cfg.remote-play.enable && cfg.remote-play.open-firewall;
      };

      dedicatedServer = {
        openFirewall = cfg.dedicated-server.enable && cfg.dedicated-server.open-firewall;
      };

      extest = {
        enable = cfg.extest;
      };

      gamescopeSession = {
        enable = cfg.gamescope-session;
      };

      protontricks = {
        enable = cfg.protontricks;
      };

      extraCompatPackages = cfg.extra-compat-packages;
    };
  };
}
