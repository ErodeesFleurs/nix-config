{ config, themeLib }:

themeLib.mkColorApp {
  name = "Fastfetch";
  enable = config.programs.fastfetch.enable;
  template = ./templates/fastfetch.jsonc;
  themePath = "fastfetch/config.jsonc";
  configPath = ".config/fastfetch/config.jsonc";
  colors = [
    "primary"
    "tertiary"
  ];
  literalReplacements = [
    {
      token = "home_dir";
      value = themeLib.homeDir;
    }
  ];
}
