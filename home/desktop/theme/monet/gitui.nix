{ config, themeLib }:

let
  enabled = config.programs.gitui.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/gitui" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/gitui.ron;
      target = "$out/gitui/theme.ron";
      inherit polarity;
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
    };

  xdgPlaceholders = [
    {
      path = "gitui/theme.ron";
      text = "// Managed by Monet theme activation\n";
    }
  ];

  links = [
    {
      name = "Gitui";
      target = ".config/gitui/theme.ron";
      source = "gitui/theme.ron";
    }
  ];
}
