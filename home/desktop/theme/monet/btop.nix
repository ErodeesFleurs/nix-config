{ config, themeLib }:

themeLib.mkColorApp {
  name = "Btop";
  enable = config.homeModules.terminal.btop.enable;
  template = ./templates/btop.theme;
  themePath = "btop/themes/monet.theme";
  configPath = ".config/btop/themes/monet.theme";
  colors = [
    "surface_container_low"
    "on_surface"
    "primary"
    "primary_container"
    "on_primary_container"
    "on_surface_variant"
    "surface_container_highest"
    "tertiary"
    "outline_variant"
    "error"
    "secondary_container"
    "secondary"
    "surface_container_high"
    "tertiary_container"
  ];
}
