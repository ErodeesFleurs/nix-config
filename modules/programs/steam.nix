{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.programs.steam;
in
{
  options.modules.programs.steam = {
    enable = lib.mkEnableOption "Steam gaming platform";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;

      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;

      extest.enable = true;

      gamescopeSession.enable = false;

      protontricks.enable = true;

      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };
  };
}
