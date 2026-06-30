{ config, themeLib }:

let
  enabled = config.programs.ghostty.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/ghostty/themes" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/ghostty.theme;
      target = "$out/ghostty/themes/monet";
      inherit polarity;
      colors = [
        "surface_container_lowest"
        "on_surface"
        "primary"
        "on_primary"
        "primary_container"
        "on_primary_container"
        "tertiary_container"
        "on_tertiary_container"
        "outline_variant"
        "surface_container"
        "surface_container_high"
        "error"
        "tertiary"
        "secondary"
        "inverse_surface"
      ];
    };

  links = [
    {
      name = "Ghostty";
      target = ".config/ghostty/themes/monet";
      source = "ghostty/themes/monet";
    }
  ];
}
