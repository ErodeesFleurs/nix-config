{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.display-manager.tuigreet;
  theme = config.modules.desktop.theme.monet;

  tuigreetCommand =
    if theme.enable then
      pkgs.writeShellScript "tuigreet-monet" ''
        set -euo pipefail

        exec ${pkgs.tuigreet}/bin/tuigreet --theme "$(${pkgs.coreutils}/bin/cat ${theme.tuigreet.themeSpec})" "$@"
      ''
    else
      "${pkgs.tuigreet}/bin/tuigreet";
in
{
  options.modules.display-manager.tuigreet = {
    enable = lib.mkEnableOption "Tuigreet greeter";
  };

  config = lib.mkIf cfg.enable {
    environment.defaultPackages = with pkgs; [ tuigreet ];

    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session = {
          command = lib.concatStringsSep " " [
            "${tuigreetCommand}"
            "--time"
            "--time-format '%Y-%m-%d %H:%M'"
            "--asterisks"
            "--remember"
          ];
          user = "greeter";
        };
      };
    };
  };
}
