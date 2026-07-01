{ themeLib }:

themeLib.mkApp {
  enable = true;
  outputDirs = [
    "$out/gtk-3.0"
    "$out/gtk-4.0"
  ];

  generate =
    { polarity }:
    let
      renderGtkCss = target: ''
        ${themeLib.renderTemplate {
          source = ./templates/gtk.css;
          inherit target polarity;
          colors = [
            "surface"
            "surface_container_lowest"
            "surface_container_low"
            "surface_container"
            "surface_container_high"
            "surface_container_highest"
            "on_surface"
            "on_surface_variant"
            "outline"
            "outline_variant"
            "primary"
            "on_primary"
            "primary_container"
            "on_primary_container"
            "tertiary"
            "tertiary_container"
            "error"
            "error_container"
            "on_error_container"
          ];
        }}
      '';
    in
    ''
      ${renderGtkCss "$out/gtk-3.0/gtk.css"}
      ${renderGtkCss "$out/gtk-4.0/gtk.css"}
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
  ];
}
