{ config, themeLib }:

themeLib.mkColorApp {
  name = "Niri";
  enable = config.programs.niri.enable;
  template = ./templates/niri.kdl;
  themePath = "niri/monet.kdl";
  configPath = ".config/niri/monet.kdl";
  placeholder = true;
}
