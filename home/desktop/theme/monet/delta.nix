{ config, themeLib }:

themeLib.mkColorApp {
  name = "Delta";
  enable = config.programs.delta.enable && config.programs.git.enable;
  template = ./templates/delta.gitconfig;
  themePath = "git/monet-delta.gitconfig";
  configPath = ".config/git/monet-delta.gitconfig";
  placeholder = true;
  colors = [
    "surface"
    "surface_container_low"
    "surface_container"
    "surface_container_high"
    "on_surface_variant"
    "outline"
    "outline_variant"
    "primary"
    "primary_container"
    "error"
    "error_container"
  ];
}
