{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.theme;
in
{
  options.homeModules.theme = {
    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = ../../../assets/wallpaper.jpg;
      description = "Wallpaper image used as the source for local theme generation";
    };

    fonts = {
      emoji = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.noto-fonts-color-emoji;
          description = "Emoji font package";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "Noto Color Emoji";
          description = "Emoji font family name";
        };
      };

      monospace = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.nerd-fonts.caskaydia-mono;
          description = "Monospace font package";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "CaskaydiaMono Nerd Font Mono";
          description = "Monospace font family name";
        };
      };

      sans-serif = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.source-han-sans;
          description = "Sans-serif font package";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "Source Han Sans SC";
          description = "Sans-serif font family name";
        };
      };

      serif = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.source-han-serif;
          description = "Serif font package";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "Source Han Serif SC";
          description = "Serif font family name";
        };
      };
    };

    opacity = {
      terminal = lib.mkOption {
        type = lib.types.float;
        default = 0.92;
        description = "Terminal background opacity from 0.0 to 1.0";
      };
    };

    icons = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.papirus-icon-theme;
        description = "Icon theme package";
      };

      lightName = lib.mkOption {
        type = lib.types.str;
        default = "Monet-Papirus-Light";
        description = "Icon theme name for light mode";
      };

      darkName = lib.mkOption {
        type = lib.types.str;
        default = "Monet-Papirus-Dark";
        description = "Icon theme name for dark mode";
      };
    };

    cursor = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.adwaita-icon-theme;
        description = "Cursor theme package";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "Adwaita";
        description = "Cursor theme name";
      };

      size = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "Cursor size";
      };
    };
  };

  config = {
    home.packages = [
      cfg.fonts.emoji.package
      cfg.fonts.monospace.package
      cfg.fonts.sans-serif.package
      cfg.fonts.serif.package
      cfg.cursor.package
      cfg.icons.package
    ];

    fonts.fontconfig.enable = true;

    home.pointerCursor = {
      enable = true;
      package = cfg.cursor.package;
      name = cfg.cursor.name;
      size = cfg.cursor.size;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
