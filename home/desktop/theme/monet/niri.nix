{ config, themeLib }:

themeLib.mkColorApp {
  name = "Niri";
  enable = config.programs.niri.enable;
  template = ./templates/niri.kdl;
  themePath = "niri/monet.kdl";
  configPath = ".config/niri/monet.kdl";
  placeholder = true;
  colors = [
    "surface"
    "surface_container_lowest"
    "surface_container_highest"
    "outline"
    "outline_variant"
    "primary"
    "primary_container"
    "tertiary"
    "tertiary_container"
    "error"
    "error_container"
  ];
}
