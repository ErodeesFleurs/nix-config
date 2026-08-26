{ config, themeLib }:

themeLib.mkColorApp {
  name = "Gitui";
  enable = config.programs.gitui.enable;
  template = ./templates/gitui.ron;
  themePath = "gitui/theme.ron";
  configPath = ".config/gitui/theme.ron";
  placeholder = true;
  placeholderText = "// Managed by Monet theme activation\n";
  colors = [
    "primary"
    "on_primary_container"
    "primary_container"
    "surface_container_high"
    "on_surface_variant"
    "secondary_container"
    "error_container"
    "secondary"
    "error"
    "tertiary"
  ];
}
