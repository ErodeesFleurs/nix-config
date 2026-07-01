{ lib, pkgs }:

let
  schemes = [
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

  modes = [
    "dark"
    "light"
  ];
in
rec {
  inherit schemes modes;

  mkEnableOption =
    description:
    lib.mkOption {
      type = lib.types.bool;
      default = true;
      inherit description;
    };

  mkModeOption =
    {
      default ? "dark",
      description,
    }:
    lib.mkOption {
      type = lib.types.enum modes;
      inherit default description;
    };

  mkSchemeOption =
    {
      default,
      description,
    }:
    lib.mkOption {
      type = lib.types.enum schemes;
      inherit default description;
    };

  mkSourceColorIndexOption =
    {
      default ? 0,
      description,
    }:
    lib.mkOption {
      type = lib.types.int;
      inherit default description;
    };

  mkFallbackColorOption =
    {
      default,
      description,
    }:
    lib.mkOption {
      type = lib.types.str;
      inherit default description;
    };

  mkWallpaperOption =
    {
      default,
      description,
      nullable ? false,
    }:
    lib.mkOption {
      type = if nullable then lib.types.nullOr lib.types.path else lib.types.path;
      inherit default description;
    };

  mkMatugenImageCommand =
    {
      mode,
      scheme,
      sourceColorIndex,
      fallbackColor,
      output ? "colors.json",
      outputIsShellExpression ? false,
    }:
    let
      outputTarget = if outputIsShellExpression then output else lib.escapeShellArg output;
    in
    ''
      ${pkgs.matugen}/bin/matugen image \
        --json hex \
        --mode ${mode} \
        --type ${scheme} \
        --source-color-index ${toString sourceColorIndex} \
        --fallback-color ${lib.escapeShellArg fallbackColor} \
        "$wallpaperPath" > ${outputTarget}
    '';

  mkColorsJson =
    {
      name,
      mode,
      wallpaper,
      scheme,
      sourceColorIndex,
      fallbackColor,
    }:
    pkgs.runCommand name
      {
        wallpaperPath = wallpaper;
      }
      ''
        ${mkMatugenImageCommand {
          inherit
            mode
            scheme
            sourceColorIndex
            fallbackColor
            ;
          output = "$out";
          outputIsShellExpression = true;
        }}
      '';
}
