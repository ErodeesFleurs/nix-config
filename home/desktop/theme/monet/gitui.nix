{ config, themeLib }:

themeLib.mkColorApp {
  name = "Gitui";
  enable = config.programs.gitui.enable;
  template = ./templates/gitui.ron;
  themePath = "gitui/theme.ron";
  configPath = ".config/gitui/theme.ron";
  placeholder = true;
  placeholderText = "// Managed by Monet theme activation\n";
}
