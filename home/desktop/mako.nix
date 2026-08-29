{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.mako;
in
{
  options.homeModules.mako = {
    enable = lib.mkEnableOption "Mako notification daemon";

    # 单一数据源：同时应用于 services.mako.settings（回退）与 monet 主题模板
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        width = 360;
        height = 145;
        anchor = "top-right";
        outer-margin = "15,15";
        margin = 12;
        padding = "20,20";
        border-size = 1;
        border-radius = 24;
        icons = 1;
        icon-location = "left";
        max-icon-size = 64;
        markup = 1;
        format = "<b>%s</b>\\n%b";
        text-alignment = "left";
        history = 1;
        max-history = 20;
        default-timeout = 6000;
        layer = "top";
        on-button-left = "invoke-default-action";
        on-button-middle = "dismiss-all";
        on-button-right = "dismiss";

        "urgency=low" = {
          default-timeout = 4000;
        };
        "urgency=critical" = {
          default-timeout = 0;
          ignore-timeout = 1;
        };
      };
      description = "Mako settings table (single source of truth).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mako = {
      enable = true;
      inherit (cfg) settings;
    };
  };
}
