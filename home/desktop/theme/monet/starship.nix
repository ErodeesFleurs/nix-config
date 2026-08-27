{ config, themeLib }:

themeLib.mkColorApp {
  name = "Starship";
  enable = config.programs.starship.enable;
  template = ./templates/starship.toml;
  themePath = "starship/starship.toml";
  configPath = ".config/starship.toml";
}
