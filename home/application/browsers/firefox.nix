{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.firefox;
in
{
  options.homeModules.firefox = {
    enable = lib.mkEnableOption "Firefox web browser";

    profileName = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "Firefox profile name";
    };

    forceExtensions = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Force extensions to be installed";
    };

    enableStylix = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply Stylix theme to Firefox";
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional Firefox settings";
      example = {
        "browser.startup.homepage" = "https://nixos.org";
        "privacy.trackingprotection.enabled" = true;
      };
    };

    search = {
      default = lib.mkOption {
        type = lib.types.str;
        default = "google";
        description = "Default search engine";
      };

      force = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Force default search engine";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;

      profiles.${cfg.profileName} = {
        extensions = {
          force = cfg.forceExtensions;
        };

        search = {
          default = cfg.search.default;
          force = cfg.search.force;
        };

        settings = cfg.extraSettings;
      };
    };

    # Stylix integration
    stylix.targets.firefox = lib.mkIf cfg.enableStylix {
      colorTheme.enable = true;
      profileNames = [ cfg.profileName ];
    };
  };
}
