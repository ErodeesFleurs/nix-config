{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.desktop.theme.monet;

  mkColorsJson =
    {
      mode,
      wallpaper,
      scheme,
      sourceColorIndex,
      fallbackColor,
    }:
    pkgs.runCommand "system-monet-colors-${mode}"
      {
        nativeBuildInputs = [ pkgs.matugen ];
        wallpaperPath = wallpaper;
      }
      ''
        matugen image \
          --json hex \
          --mode ${mode} \
          --type ${scheme} \
          --source-color-index ${toString sourceColorIndex} \
          --fallback-color ${lib.escapeShellArg fallbackColor} \
          "$wallpaperPath" > "$out"
      '';

  mkTuigreetThemeSpec =
    {
      mode,
      colorsJson,
    }:
    pkgs.runCommand "tuigreet-monet-theme-${mode}"
      {
        nativeBuildInputs = [ pkgs.jq ];
      }
      ''
        jq -r ${lib.escapeShellArg ''
          def c(name): .colors[name]["${mode}"].color;
          [
            "text=" + c("on_surface"),
            "time=" + c("primary"),
            "container=" + c("surface_container"),
            "border=" + c("outline_variant"),
            "title=" + c("primary"),
            "greet=" + c("on_surface"),
            "prompt=" + c("primary"),
            "input=" + c("on_surface"),
            "action=" + c("on_surface_variant"),
            "button=" + c("primary")
          ] | join(";")
        ''} ${colorsJson} > "$out"
      '';

  colorsJson = mkColorsJson {
    inherit (cfg)
      mode
      wallpaper
      scheme
      sourceColorIndex
      fallbackColor
      ;
  };

  tuigreetThemeSpec = mkTuigreetThemeSpec {
    inherit (cfg) mode;
    inherit colorsJson;
  };
in
{
  options.modules.desktop.theme.monet = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Generate system-level Material You / Monet theme resources from wallpaper colors.";
    };

    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = ../../../assets/wallpaper.jpg;
      description = "Wallpaper image used as the source for system-level Monet colors.";
    };

    mode = lib.mkOption {
      type = lib.types.enum [
        "dark"
        "light"
      ];
      default = "dark";
      description = "Matugen polarity used for static system-level theme resources.";
    };

    scheme = lib.mkOption {
      type = lib.types.enum [
        "scheme-content"
        "scheme-expressive"
        "scheme-fidelity"
        "scheme-fruit-salad"
        "scheme-monochrome"
        "scheme-neutral"
        "scheme-rainbow"
        "scheme-tonal-spot"
        "scheme-vibrant"
      ];
      default = "scheme-expressive";
      description = "Matugen dynamic color scheme variant for system-level theme resources.";
    };

    sourceColorIndex = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Matugen source color index selected from the wallpaper palette.";
    };

    fallbackColor = lib.mkOption {
      type = lib.types.str;
      default = "#6750A4";
      description = "Fallback source color used when wallpaper extraction cannot produce a color.";
    };

    colorsJson = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      description = "Generated matugen JSON colors for system-level theme consumers.";
    };

    tuigreet.themeSpec = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      description = "Generated tuigreet --theme specification derived from system-level Monet colors.";
    };
  };

  config = lib.mkIf cfg.enable {
    modules.desktop.theme.monet = {
      inherit colorsJson;
      tuigreet.themeSpec = tuigreetThemeSpec;
    };
  };
}
