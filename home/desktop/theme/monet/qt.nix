{ config, themeLib }:

let
  inherit (themeLib) currentSymlink;

  mkQtctConf =
    {
      style,
      iconTheme,
      colorSchemePath,
    }:
    builtins.toFile "qtct.conf" ''
      [Appearance]
      color_scheme_path=${colorSchemePath}
      custom_palette=true
      icon_theme=${iconTheme}
      style=${style}
    '';
in
themeLib.mkApp {
  enable = true;
  outputDirs = [ "$out/qt6ct/colors" ];

  templates = [
    {
      name = "qtct-colors";
      input = themeLib.materialize { source = ./templates/qtct-colors.conf; };
      output = "qt6ct/colors/monet.conf";
    }
  ];

  # qtct.conf 为纯字面值（style/iconTheme 随 polarity）
  postSteps =
    { polarity }:
    let
      style = config.homeModules.desktop.darkman.${polarity}.qt5ctStyle;
      iconTheme = config.homeModules.desktop.darkman.${polarity}.iconTheme;
    in
    ''
      cp ${
        mkQtctConf {
          inherit iconTheme style;
          colorSchemePath = "${currentSymlink}/qt6ct/colors/monet.conf";
        }
      } "$out/qt6ct/qt6ct.conf"
    '';
}
