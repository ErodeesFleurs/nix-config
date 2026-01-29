{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.vicinae;
in
{
  options.homeModules.vicinae = {
    enable = lib.mkEnableOption "Vicinae (neighborhood notification/status tool)";

    auto-start = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically start Vicinae on login";
    };

    use-layer-shell = lib.mkOption {
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
      systemd = {
        enable = true;
        autoStart = cfg.auto-start;
        environment = lib.mkIf cfg.use-layer-shell {
          USE_LAYER_SHELL = 1;
        };
      };
      settings = cfg.settings;

      package = pkgs.vicinae;
    };
  };
}
