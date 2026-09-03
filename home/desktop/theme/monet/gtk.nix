{
  config,
  lib,
  themeLib,
}:

let
  # settings.ini 无颜色 token，纯字面值，按 polarity 在构建期生成
  mkSettings =
    polarity:
    let
      darkmanConfig = config.homeModules.desktop.darkman.${polarity};
    in
    builtins.toFile "gtk-settings-${polarity}.ini" ''
      [Settings]
      gtk-theme-name=${darkmanConfig.gtkTheme}
      gtk-icon-theme-name=${darkmanConfig.iconTheme}
      gtk-cursor-theme-name=${darkmanConfig.cursorTheme}
      gtk-cursor-theme-size=${toString darkmanConfig.cursorSize}
      gtk-application-prefer-dark-theme=${if polarity == "dark" then "true" else "false"}
    '';
in
themeLib.mkApp {
  enable = true;

  # 同一 gtk.css 模板渲染到 gtk-3.0 与 gtk-4.0 × 两棵子树
  templates =
    lib.concatMap
      (
        subtree:
        map
          (dir: {
            name = "gtk-${dir}-${subtree}";
            input = themeLib.materialize {
              source = ./templates/gtk.css;
              mode = subtree;
            };
            output = "${subtree}/${dir}/gtk.css";
          })
          [
            "gtk-3.0"
            "gtk-4.0"
          ]
      )
      [
        "light"
        "dark"
      ];

  postSteps =
    { polarity }:
    ''
      cp ${mkSettings polarity} "$out/gtk-3.0/settings.ini"
      cp ${mkSettings polarity} "$out/gtk-4.0/settings.ini"
    '';

  xdgPlaceholders = [
    {
      path = "gtk-3.0/gtk.css";
      text = "/* Managed by Monet theme activation */\n";
    }
    {
      path = "gtk-4.0/gtk.css";
      text = "/* Managed by Monet theme activation */\n";
    }
    {
      path = "gtk-3.0/settings.ini";
      text = "# Managed by Monet theme activation\n";
    }
    {
      path = "gtk-4.0/settings.ini";
      text = "# Managed by Monet theme activation\n";
    }
  ];

  links = [
    {
      name = "Gtk3";
      target = ".config/gtk-3.0/gtk.css";
      source = "gtk-3.0/gtk.css";
    }
    {
      name = "Gtk4";
      target = ".config/gtk-4.0/gtk.css";
      source = "gtk-4.0/gtk.css";
    }
    {
      name = "Gtk3Settings";
      target = ".config/gtk-3.0/settings.ini";
      source = "gtk-3.0/settings.ini";
    }
    {
      name = "Gtk4Settings";
      target = ".config/gtk-4.0/settings.ini";
      source = "gtk-4.0/settings.ini";
    }
  ];
}
