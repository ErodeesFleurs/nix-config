{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.stylix;
  theme = config.homeModules.theme;
in
{
  options.homeModules.stylix = {
    enable = lib.mkEnableOption "Stylix theme management for Home Manager";

    image = lib.mkOption {
      type = lib.types.path;
      default = ../../assets/wallpaper.jpg;
      description = "Wallpaper image for theming";
    };

    polarity = lib.mkOption {
      type = lib.types.enum [
        "light"
        "dark"
      ];
      default = "light";
      description = "Color scheme polarity";
    };

    base16-scheme = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Base16 color scheme file";
      example = lib.literalExpression ''"''${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml"'';
    };

    auto-enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically enable Stylix for all supported Home Manager programs";
    };

    cursor = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.catppuccin-cursors.mochaDark;
        description = "Cursor theme package";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "catppuccin-mocha-dark-cursors";
        description = "Cursor theme name";
      };

      size = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "Cursor size";
      };
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
          description = "Emoji font name";
        };
      };

      monospace = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.nerd-fonts.dejavu-sans-mono;
          description = "Monospace font package";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "CaskaydiaMono Nerd Font Mono";
          description = "Monospace font name";
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
          description = "Sans-serif font name";
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
          description = "Serif font name";
        };
      };
    };

    opacity = {
      terminal = lib.mkOption {
        type = lib.types.float;
        default = 0.7;
        description = "Terminal opacity (0.0 - 1.0)";
      };
    };

    targets = {

      gtk = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Apply Stylix theme to GTK applications";
        };
      };

      kde = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Apply Stylix theme to KDE/Qt applications";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {

    stylix = {
      enable = cfg.enable;
      autoEnable = cfg.auto-enable;

      image = theme.wallpaper;
      polarity = cfg.polarity;

      base16Scheme = lib.mkIf (cfg.base16-scheme != null) cfg.base16-scheme;

      cursor = {
        package = theme.cursor.package;
        name = theme.cursor.name;
        size = theme.cursor.size;
      };

      fonts = {
        emoji = {
          package = theme.fonts.emoji.package;
          name = theme.fonts.emoji.name;
        };

        monospace = {
          package = theme.fonts.monospace.package;
          name = theme.fonts.monospace.name;
        };

        sansSerif = {
          package = theme.fonts.sans-serif.package;
          name = theme.fonts.sans-serif.name;
        };

        serif = {
          package = theme.fonts.serif.package;
          name = theme.fonts.serif.name;
        };
      };

      opacity = {
        terminal = theme.opacity.terminal;
      };

      # Configure per-application targets
      targets = {
        gtk.enable = cfg.targets.gtk.enable;
        kde.enable = cfg.targets.kde.enable;
      };
    };
  };
}
