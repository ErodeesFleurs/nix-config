{ config, themeLib }:

themeLib.mkColorApp {
  name = "Yazi";
  enable = config.programs.yazi.enable;
  template = ./templates/yazi.toml;
  themePath = "yazi/theme.toml";
  configPath = ".config/yazi/theme.toml";
  placeholder = true;
  colors = [
    "primary"
    "on_primary"
    "on_primary_container"
    "primary_container"
    "secondary"
    "tertiary"
    "on_tertiary_container"
    "tertiary_container"
    "error"
    "on_error_container"
    "error_container"
    "on_surface"
    "on_surface_variant"
    "outline_variant"
    "surface_container"
    "surface_container_high"
    "surface_container_low"
  ];
}
