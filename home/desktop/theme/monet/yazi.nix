{ config, themeLib }:

let
  enabled = config.programs.yazi.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/yazi" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/yazi.toml;
      target = "$out/yazi/theme.toml";
      inherit polarity;
      colors = [
        "primary"
        "on_primary"
        "on_primary_container"
        "primary_container"
        "secondary"
        "tertiary"
        "on_tertiary_container"
        "tertiary_container"
        "error"
        "on_error_container"
        "error_container"
        "on_surface"
        "on_surface_variant"
        "outline_variant"
        "surface_container"
        "surface_container_high"
        "surface_container_low"
      ];
    };

  xdgPlaceholders = [
    { path = "yazi/theme.toml"; }
  ];

  links = [
    {
      name = "Yazi";
      target = ".config/yazi/theme.toml";
      source = "yazi/theme.toml";
    }
  ];
}
