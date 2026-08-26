{
  themeLib,
  waybarBodyCssPath,
}:

themeLib.mkColorApp {
  name = "Waybar";
  enable = true;
  template = ./templates/waybar-colors.css;
  themePath = "waybar/style.css";
  configPath = ".config/waybar/style.css";
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
    "tertiary_container"
    "on_tertiary_container"
    "error_container"
    "on_error_container"
  ];
  append = [ waybarBodyCssPath ];
  placeholder = true;
  placeholderText = "/* Managed by Monet theme activation */\n";
  postLink = themeLib.reloadScripts.waybar;
}
