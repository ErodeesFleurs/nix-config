{ config, themeLib }:

themeLib.mkColorApp {
  name = "Helix";
  enable = config.programs.helix.enable;
  template = ./templates/helix.toml;
  themePath = "helix/themes/monet.toml";
  configPath = ".config/helix/themes/monet.toml";
  colors = [
    "surface"
    "surface_container_lowest"
    "surface_container_low"
    "surface_container"
    "surface_container_high"
    "on_surface"
    "on_surface_variant"
    "outline"
    "outline_variant"
    "primary"
    "on_primary"
    "primary_container"
    "on_primary_container"
    "secondary"
    "on_secondary"
    "secondary_container"
    "tertiary"
    "on_tertiary"
    "error"
  ];
}
