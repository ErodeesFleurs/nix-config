{ config, themeLib }:

let
  enabled = config.programs.helix.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/helix/themes" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/helix.toml;
      target = "$out/helix/themes/monet.toml";
      inherit polarity;
      colors = [
        "surface"
        "surface_container_lowest"
        "surface_container_low"
        "surface_container"
        "surface_container_high"
        "on_surface"
        "on_surface_variant"
        "outline"
        "outline_variant"
        "primary"
        "on_primary"
        "primary_container"
        "on_primary_container"
        "secondary"
        "on_secondary"
        "secondary_container"
        "tertiary"
        "on_tertiary"
        "error"
      ];
    };

  links = [
    {
      name = "Helix";
      target = ".config/helix/themes/monet.toml";
      source = "helix/themes/monet.toml";
    }
  ];
}
