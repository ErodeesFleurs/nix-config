{ config, themeLib }:

let
  enabled = config.programs.delta.enable && config.programs.git.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/git" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/delta.gitconfig;
      target = "$out/git/monet-delta.gitconfig";
      inherit polarity;
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
    };

  xdgPlaceholders = [
    {
      path = "git/monet-delta.gitconfig";
      text = "# Managed by Monet theme activation\n";
    }
  ];

  links = [
    {
      name = "Delta";
      target = ".config/git/monet-delta.gitconfig";
      source = "git/monet-delta.gitconfig";
    }
  ];
}
