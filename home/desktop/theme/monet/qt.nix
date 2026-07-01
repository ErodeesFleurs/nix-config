{ config, themeLib }:

let
  inherit (themeLib) currentSymlink;

  rgbColors = [
    {
      token = "surface_rgb";
      color = "surface";
      transform = "noHash";
    }
    {
      token = "surface_container_rgb";
      color = "surface_container";
      transform = "noHash";
    }
    {
      token = "surface_container_low_rgb";
      color = "surface_container_low";
      transform = "noHash";
    }
    {
      token = "surface_container_high_rgb";
      color = "surface_container_high";
      transform = "noHash";
    }
    {
      token = "surface_container_highest_rgb";
      color = "surface_container_highest";
      transform = "noHash";
    }
    {
      token = "on_surface_rgb";
      color = "on_surface";
      transform = "noHash";
    }
    {
      token = "on_surface_variant_rgb";
      color = "on_surface_variant";
      transform = "noHash";
    }
    {
      token = "outline_rgb";
      color = "outline";
      transform = "noHash";
    }
    {
      token = "outline_variant_rgb";
      color = "outline_variant";
      transform = "noHash";
    }
    {
      token = "primary_rgb";
      color = "primary";
      transform = "noHash";
    }
    {
      token = "on_primary_rgb";
      color = "on_primary";
      transform = "noHash";
    }
    {
      token = "primary_container_rgb";
      color = "primary_container";
      transform = "noHash";
    }
    {
      token = "on_primary_container_rgb";
      color = "on_primary_container";
      transform = "noHash";
    }
    {
      token = "error_rgb";
      color = "error";
      transform = "noHash";
    }
  ];

  mkQtctConf =
    {
      style,
      colorSchemePath,
    }:
    builtins.toFile "qtct.conf" ''
      [Appearance]
      color_scheme_path=${colorSchemePath}
      custom_palette=true
      style=${style}
    '';
in
themeLib.mkApp {
  enable = true;
  outputDirs = [
    "$out/qt5ct/colors"
    "$out/qt6ct/colors"
  ];

  generate =
    { polarity }:
    let
      style = config.home-modules.desktop.darkman.${polarity}.qt5ctStyle;
    in
    ''
      ${themeLib.renderTemplate {
        source = ./templates/qtct-colors.conf;
        target = "$out/qt5ct/colors/monet.conf";
        inherit polarity;
        replacements = rgbColors;
      }}
      cp "$out/qt5ct/colors/monet.conf" "$out/qt6ct/colors/monet.conf"
      cp ${
        mkQtctConf {
          inherit style;
          colorSchemePath = "${currentSymlink}/qt5ct/colors/monet.conf";
        }
      } "$out/qt5ct/qt5ct.conf"
      cp ${
        mkQtctConf {
          inherit style;
          colorSchemePath = "${currentSymlink}/qt6ct/colors/monet.conf";
        }
      } "$out/qt6ct/qt6ct.conf"
    '';
}
