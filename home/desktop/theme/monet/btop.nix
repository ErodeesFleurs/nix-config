{ config, themeLib }:

themeLib.mkColorApp {
  name = "Btop";
  enable = config.homeModules.terminal.btop.enable;
  template = ./templates/btop.theme;
  themePath = "btop/themes/monet.theme";
  configPath = ".config/btop/themes/monet.theme";
}
