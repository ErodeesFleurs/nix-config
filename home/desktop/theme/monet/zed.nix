{ config, themeLib }:

let
  enabled = config.programs.zed-editor.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/zed/themes" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/zed-md3.json;
      target = "$out/zed/themes/monet-md3.json";
      inherit polarity;
      colors = [
        "outline_variant"
        "primary"
        "surface_container_high"
        "surface_container"
        "surface"
        "surface_container_highest"
        "primary_container"
        "on_surface"
        "on_surface_variant"
        "surface_container_low"
        "tertiary"
        "outline"
        "surface_container_lowest"
        "error"
        "secondary"
        "secondary_container"
        "error_container"
        "tertiary_container"
      ];
      literalReplacements = [
        {
          placeholder = "appearance";
          value = polarity;
        }
      ];
    };

  links = [
    {
      name = "Zed";
      target = ".config/zed/themes/monet-md3.json";
      source = "zed/themes/monet-md3.json";
    }
  ];
}
