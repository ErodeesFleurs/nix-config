{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.desktop.theme.monet;
  monetLib = import ../../../lib/monet.nix { inherit lib pkgs; };

  # tuigreet 主题模板（matugen 原生语法，无需 jq）
  tuigreetTpl = builtins.toFile "tuigreet-theme.tpl" ''
    text={{colors.on_surface.default.hex}};time={{colors.primary.default.hex}};container={{colors.surface_container.default.hex}};border={{colors.outline_variant.default.hex}};title={{colors.primary.default.hex}};greet={{colors.on_surface.default.hex}};prompt={{colors.primary.default.hex}};input={{colors.on_surface.default.hex}};action={{colors.on_surface_variant.default.hex}};button={{colors.primary.default.hex}}
  '';

  matugenConfig = builtins.toFile "matugen-config.toml" ''
    [config]
    version_check = false
    caching = false
    [templates."tuigreet"]
    input_path = "${tuigreetTpl}"
    output_path = "themeSpec"
  '';

  tuigreetThemeSpec =
    pkgs.runCommand "tuigreet-monet-theme-${cfg.mode}"
      {
        wallpaperPath = cfg.wallpaper;
      }
      ''
        cp ${matugenConfig} config.toml
        ${pkgs.matugen}/bin/matugen image \
          --mode ${cfg.mode} \
          --type ${cfg.scheme} \
          --source-color-index ${toString cfg.sourceColorIndex} \
          --fallback-color ${lib.escapeShellArg cfg.fallbackColor} \
          "$wallpaperPath" \
          -c config.toml
        mv themeSpec "$out"
      '';
in
{
  options.modules.desktop.theme.monet = {
    enable = monetLib.mkEnableOption "Generate system-level Material You / Monet theme resources from wallpaper colors.";

    wallpaper = monetLib.mkWallpaperOption {
      # builtins.path 单独拷贝入 store（按内容寻址），避免仓库改动触发主题重建
      default = builtins.path {
        path = ../../../assets/wallpaper.jpg;
        name = "wallpaper.jpg";
      };
      description = "Wallpaper image used as the source for system-level Monet colors.";
    };

    mode = monetLib.mkModeOption {
      default = monetLib.defaults.mode;
      description = "Matugen polarity used for static system-level theme resources.";
    };

    scheme = monetLib.mkSchemeOption {
      default = monetLib.defaults.scheme;
      description = "Matugen dynamic color scheme variant for system-level theme resources.";
    };

    sourceColorIndex = monetLib.mkSourceColorIndexOption {
      default = monetLib.defaults.sourceColorIndex;
      description = "Matugen source color index selected from the wallpaper palette.";
    };

    fallbackColor = monetLib.mkFallbackColorOption {
      default = monetLib.defaults.fallbackColor;
      description = "Fallback source color used when wallpaper extraction cannot produce a color.";
    };

    tuigreet.themeSpec = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      description = "Generated tuigreet --theme specification derived from system-level Monet colors.";
    };
  };

  config = lib.mkIf cfg.enable {
    modules.desktop.theme.monet.tuigreet.themeSpec = tuigreetThemeSpec;
  };
}
