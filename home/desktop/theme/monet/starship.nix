{ config, themeLib }:

themeLib.mkColorApp {
  name = "Starship";
  enable = config.programs.starship.enable;
  template = ./templates/starship.toml;
  themePath = "starship/starship.toml";
  configPath = ".config/starship.toml";
  colors = [
    "primary"
    "secondary"
    "tertiary"
    "error"
    "surface"
    "on_surface"
    "on_surface_variant"
    "outline"
  ];
}
