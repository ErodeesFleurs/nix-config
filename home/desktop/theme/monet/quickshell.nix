{ config, themeLib }:

themeLib.mkColorApp {
  name = "Quickshell";
  enable = config.homeModules.desktop.quickshell.enable;
  template = ./templates/quickshell-palette.json;
  themePath = "quickshell/palette.json";
  literalsFor = polarity: { mode = polarity; };
}
