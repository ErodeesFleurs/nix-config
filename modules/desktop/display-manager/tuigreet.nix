{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.display-manager.tuigreet;
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
          command = ''
            tuigreet \
            --time \
            --time-format '%Y-%m-%d %H:%M' \
            --asterisks \
            --remember'';
          user = "greeter";
        };
      };
    };
  };
}
