{ config, themeLib }:

let
  enabled = config.homeModules.discord.enable or false;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/discord" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/discord.css;
      target = "$out/discord/monet.css";
      inherit polarity;
      colors = [
        "surface"
        "surface_container_low"
        "surface_container"
        "surface_container_high"
        "surface_container_highest"
        "on_surface"
        "on_surface_variant"
        "outline"
        "outline_variant"
        "primary"
        "on_primary"
        "primary_container"
        "on_primary_container"
        "secondary"
        "secondary_container"
        "on_secondary_container"
        "tertiary"
        "tertiary_container"
        "on_tertiary_container"
        "error"
        "error_container"
        "on_error_container"
      ];
    };
}
