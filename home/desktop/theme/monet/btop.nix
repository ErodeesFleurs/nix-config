{ config, themeLib }:

let
  enabled = config.homeModules.terminal.btop.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/btop/themes" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/btop.theme;
      target = "$out/btop/themes/monet.theme";
      inherit polarity;
      colors = [
        "surface_container_lowest"
        "on_surface"
        "primary"
        "primary_container"
        "on_primary_container"
        "on_surface_variant"
        "surface_container_highest"
        "tertiary"
        "outline_variant"
        "error"
        "secondary_container"
        "secondary"
        "surface_container_high"
        "tertiary_container"
      ];
    };

  links = [
    {
      name = "Btop";
      target = ".config/btop/themes/monet.theme";
      source = "btop/themes/monet.theme";
    }
  ];
}
