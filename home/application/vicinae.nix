{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.vicinae;
in
{
  options.homeModules.vicinae = {
    enable = lib.mkEnableOption "Vicinae (neighborhood notification/status tool)";

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically start Vicinae on login";
    };

    useLayerShell = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use layer shell protocol for window positioning";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional settings for Vicinae";
      example = {
        position = "top";
        height = 30;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.vicinae = {
      enable = true;
      autoStart = cfg.autoStart;
      useLayerShell = cfg.useLayerShell;
      settings = cfg.settings;
    };
  };
}
