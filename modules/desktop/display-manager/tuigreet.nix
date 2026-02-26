{
  config,
  lib,
  pkgs,
  ...
}:
let
  tuigreet = "${lib.getExe pkgs.greetd.tuigreet}";
  niri-session = lib.getExe' config.modules.compositor.niri.package "niri-session";
  cfg = config.modules.display-manager.tuigreet;
in
{
  options.modules.display-manager.tuigreet = {
    enable = lib.mkEnableOption "Tuigreet greeter";
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = ''
            ${tuigreet} \
            --sessions ${niri-session} \
            --time \
            --time-format '%Y-%m-%d %H:%M' \
            --asterisks \
            --remember \
            --remember-sessiony'';
          user = "greeter";
        };
      };
    };
  };
}
