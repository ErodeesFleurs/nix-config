{ config, themeLib }:

themeLib.mkColorApp {
  name = "Helix";
  enable = config.programs.helix.enable;
  template = ./templates/helix.toml;
  themePath = "helix/themes/monet.toml";
  configPath = ".config/helix/themes/monet.toml";
}
