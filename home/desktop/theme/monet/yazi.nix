{ config, themeLib }:

themeLib.mkColorApp {
  name = "Yazi";
  enable = config.programs.yazi.enable;
  template = ./templates/yazi.toml;
  themePath = "yazi/theme.toml";
  configPath = ".config/yazi/theme.toml";
  placeholder = true;
}
