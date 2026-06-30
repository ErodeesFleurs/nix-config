{ config, themeLib }:

let
  enabled = config.programs.niri.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/niri" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/niri.kdl;
      target = "$out/niri/monet.kdl";
      inherit polarity;
      colors = [
        "surface"
        "surface_container_lowest"
        "surface_container_highest"
        "outline"
        "outline_variant"
        "primary"
        "primary_container"
        "tertiary"
        "tertiary_container"
        "error"
        "error_container"
      ];
    };

  xdgPlaceholders = [
    { path = "niri/monet.kdl"; }
  ];

  links = [
    {
      name = "Niri";
      target = ".config/niri/monet.kdl";
      source = "niri/monet.kdl";
    }
  ];
}
