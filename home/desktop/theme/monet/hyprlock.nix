{ config, themeLib }:

themeLib.mkColorApp {
  name = "Hyprlock";
  enable = config.programs.hyprlock.enable;
  template = ./templates/hyprlock.conf;
  themePath = "hypr/hyprlock.conf";
  configPath = ".config/hypr/hyprlock.conf";
  placeholder = true;
  literals.font_family = config.homeModules.theme.fonts.monospace.name;
}
