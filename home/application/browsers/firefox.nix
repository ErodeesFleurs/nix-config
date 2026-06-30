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

    profile-name = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "Firefox profile name";
    };

    force-extensions = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Force extensions to be installed";
    };

    enable-monet = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply generated Monet / Material Design 3 chrome styles to Firefox";
    };

    extra-settings = lib.mkOption {
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

      profiles.${cfg.profile-name} = {
        extensions = {
          force = cfg.force-extensions;
        };

        search = {
          default = cfg.search.default;
          force = cfg.search.force;
        };

        settings =
          lib.optionalAttrs cfg.enable-monet {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "browser.theme.content-theme" = 0;
            "browser.theme.toolbar-theme" = 0;
          }
          // cfg.extra-settings;
      };
    };

    stylix.targets.firefox = {
      enable = lib.mkForce false;
      colorTheme.enable = lib.mkForce false;
    };
  };
}
