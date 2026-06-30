{ config, themeLib }:

let
  enabled = config.programs.starship.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/starship" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/starship.toml;
      target = "$out/starship/starship.toml";
      inherit polarity;
      colors = [
        "primary"
        "secondary"
        "tertiary"
        "error"
        "surface"
        "on_surface"
        "on_surface_variant"
        "outline"
      ];
    };

  links = [
    {
      name = "Starship";
      target = ".config/starship.toml";
      source = "starship/starship.toml";
    }
  ];
}
