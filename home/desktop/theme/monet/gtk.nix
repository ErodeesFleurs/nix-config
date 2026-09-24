{
  config,
  lib,
  themeLib,
}:

let
  # settings.ini 无颜色 token，纯字面值，按 polarity 在构建期生成
  mkSettings =
    polarity: gtkVersion:
    let
      darkmanConfig = config.homeModules.desktop.darkman.${polarity};
    in
    builtins.toFile "gtk-settings-${polarity}.ini" ''
      [Settings]
      gtk-theme-name=${darkmanConfig.gtkTheme}
      gtk-icon-theme-name=${darkmanConfig.iconTheme}
      gtk-cursor-theme-name=${darkmanConfig.cursorTheme}
      gtk-cursor-theme-size=${toString darkmanConfig.cursorSize}
      ${lib.optionalString (gtkVersion == 3)
        "gtk-application-prefer-dark-theme=${if polarity == "dark" then "true" else "false"}"
      }
    '';
in
themeLib.mkApp {
  enable = true;

  # GTK3 keeps its legacy stylesheet; GTK4 uses libadwaita's public palette API.
  templates =
    lib.concatMap
      (
        subtree:
        map
          (gtkVersion: {
            name = "gtk-${toString gtkVersion}-${subtree}";
            input = themeLib.materialize {
              source = if gtkVersion == 3 then ./templates/gtk.css else ./templates/gtk4.css;
              mode = subtree;
            };
            output = "${subtree}/gtk-${toString gtkVersion}.0/${
              if gtkVersion == 3 then "gtk.css" else "palette.css"
            }";
          })
          [
            3
            4
          ]
      )
      [
        "light"
        "dark"
      ];

  postSteps =
    { polarity }:
    ''
      cp ${mkSettings polarity 3} "$out/gtk-3.0/settings.ini"
      cp ${mkSettings polarity 4} "$out/gtk-4.0/settings.ini"
      ${lib.optionalString (polarity == "light") ''
        # Both wallpaper palettes have been rendered before postSteps run.
        # GTK4 caches user CSS: media queries switch its palette without a restart.
        {
          cat "$out/gtk-4.0/palette.css"
          echo '@media (prefers-color-scheme: dark) {'
          cat "$out/../dark/gtk-4.0/palette.css"
          echo '}'
        } > "$out/gtk-4.0/gtk.css"
        cp "$out/gtk-4.0/gtk.css" "$out/../dark/gtk-4.0/gtk.css"
        rm "$out/gtk-4.0/palette.css" "$out/../dark/gtk-4.0/palette.css"
      ''}
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
