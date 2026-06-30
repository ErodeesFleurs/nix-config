{
  pkgs,
  themeLib,
  waybarBodyCssPath,
}:

themeLib.mkApp {
  enable = true;
  outputDirs = [ "$out/waybar" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/waybar-colors.css;
      target = "$out/waybar/style.css";
      inherit polarity;
      colors = [
        "surface"
        "surface_container"
        "surface_container_high"
        "on_surface"
        "on_surface_variant"
        "outline"
        "primary"
        "on_primary"
        "primary_container"
        "on_primary_container"
        "secondary_container"
        "on_secondary_container"
        "error_container"
        "on_error_container"
      ];
      append = [ waybarBodyCssPath ];
    };

  xdgPlaceholders = [
    {
      path = "waybar/style.css";
      text = "/* Managed by Monet theme activation */\n";
    }
  ];

  links = [
    {
      name = "Waybar";
      target = ".config/waybar/style.css";
      source = "waybar/style.css";
      postLink = ''
        ${pkgs.procps}/bin/pkill -SIGUSR2 waybar 2>/dev/null || true
      '';
    }
  ];
}
