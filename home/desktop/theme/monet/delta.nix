{ config, themeLib }:

themeLib.mkColorApp {
  name = "Delta";
  enable = config.programs.delta.enable && config.programs.git.enable;
  template = ./templates/delta.gitconfig;
  themePath = "git/monet-delta.gitconfig";
  configPath = ".config/git/monet-delta.gitconfig";
  placeholder = true;
}
