{ config, themeLib }:

themeLib.mkColorApp {
  name = "Fastfetch";
  enable = config.programs.fastfetch.enable;
  template = ./templates/fastfetch.jsonc;
  themePath = "fastfetch/config.jsonc";
  configPath = ".config/fastfetch/config.jsonc";
  literals.home_dir = themeLib.homeDir;
}
