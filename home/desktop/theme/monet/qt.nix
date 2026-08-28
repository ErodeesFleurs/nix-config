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

  # 配色按子树的 polarity 渲染
  templates =
    map
      (polarity: {
        name = "qtct-colors-${polarity}";
        input = themeLib.materialize {
          source = ./templates/qtct-colors.conf;
          mode = polarity;
        };
        output = "${polarity}/qt6ct/colors/monet.conf";
      })
      [
        "light"
        "dark"
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
