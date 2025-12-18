{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.stylix;
in
{
  options.modules.stylix = {
    enable = lib.mkEnableOption "Stylix system-wide theming";

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

    base16Scheme = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Base16 color scheme file";
      example = lib.literalExpression ''"''${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml"'';
    };

    autoEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically theme all supported programs";
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

      sansSerif = {
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

    enableReleaseChecks = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable release checks for Stylix";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = cfg.autoEnable;

      image = cfg.image;
      polarity = cfg.polarity;

      base16Scheme = lib.mkIf (cfg.base16Scheme != null) cfg.base16Scheme;

      cursor = {
        package = cfg.cursor.package;
        name = cfg.cursor.name;
        size = cfg.cursor.size;
      };

      fonts = {
        emoji = {
          package = cfg.fonts.emoji.package;
          name = cfg.fonts.emoji.name;
        };

        monospace = {
          package = cfg.fonts.monospace.package;
          name = cfg.fonts.monospace.name;
        };

        sansSerif = {
          package = cfg.fonts.sansSerif.package;
          name = cfg.fonts.sansSerif.name;
        };

        serif = {
          package = cfg.fonts.serif.package;
          name = cfg.fonts.serif.name;
        };
      };

      opacity = {
        terminal = cfg.opacity.terminal;
      };

      enableReleaseChecks = cfg.enableReleaseChecks;
    };
  };
}
