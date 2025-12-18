{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.display-manager;
in
{
  options.modules.display-manager = {
    enable = lib.mkEnableOption "SDDM display manager";

    wayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Wayland support";
    };

    autoNumlock = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable numlock on boot";
    };

    theme = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "catppuccin-latte-sky";
        description = "SDDM theme name";
      };

      flavor = lib.mkOption {
        type = lib.types.str;
        default = "latte";
        description = "Catppuccin flavor";
      };

      accent = lib.mkOption {
        type = lib.types.str;
        default = "sky";
        description = "Catppuccin accent color";
      };

      font = lib.mkOption {
        type = lib.types.str;
        default = "CaskaydiaMonoNerdFont";
        description = "Theme font";
      };

      fontSize = lib.mkOption {
        type = lib.types.str;
        default = "9";
        description = "Theme font size";
      };

      background = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = ../../assets/wallpaper.jpg;
        description = "Background image path";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = cfg.wayland;
      package = pkgs.kdePackages.sddm;
      autoNumlock = cfg.autoNumlock;
      theme = cfg.theme.name;
    };

    environment.systemPackages = [
      (pkgs.catppuccin-sddm.override {
        flavor = cfg.theme.flavor;
        accent = cfg.theme.accent;
        font = cfg.theme.font;
        fontSize = cfg.theme.fontSize;
        background = toString cfg.theme.background;
        loginBackground = true;
      })
    ];
  };
}
