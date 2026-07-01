{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.desktop.theme.monet;
  monetLib = import ../../../lib/monet.nix { inherit lib pkgs; };

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

  colorsJson = monetLib.mkColorsJson {
    name = "system-monet-colors-${cfg.mode}";
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
    enable = monetLib.mkEnableOption "Generate system-level Material You / Monet theme resources from wallpaper colors.";

    wallpaper = monetLib.mkWallpaperOption {
      default = ../../../assets/wallpaper.jpg;
      description = "Wallpaper image used as the source for system-level Monet colors.";
    };

    mode = monetLib.mkModeOption {
      default = "dark";
      description = "Matugen polarity used for static system-level theme resources.";
    };

    scheme = monetLib.mkSchemeOption {
      default = "scheme-expressive";
      description = "Matugen dynamic color scheme variant for system-level theme resources.";
    };

    sourceColorIndex = monetLib.mkSourceColorIndexOption {
      default = 0;
      description = "Matugen source color index selected from the wallpaper palette.";
    };

    fallbackColor = monetLib.mkFallbackColorOption {
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
