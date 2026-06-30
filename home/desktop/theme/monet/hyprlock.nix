{ config, themeLib }:

let
  enabled = config.programs.hyprlock.enable;
  font = config.homeModules.theme.fonts.monospace.name;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/hypr" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/hyprlock.conf;
      target = "$out/hypr/hyprlock.conf";
      inherit polarity;
      replacements = [
        {
          token = "outline_variant_rgb";
          color = "outline_variant";
          transform = "noHash";
        }
        {
          token = "surface_container_high_rgb";
          color = "surface_container_high";
          transform = "noHash";
        }
        {
          token = "on_surface_rgb";
          color = "on_surface";
          transform = "noHash";
        }
        {
          token = "primary_rgb";
          color = "primary";
          transform = "noHash";
        }
        {
          token = "error_rgb";
          color = "error";
          transform = "noHash";
        }
        {
          token = "on_surface_variant_rgb";
          color = "on_surface_variant";
          transform = "noHash";
        }
      ];
      literalReplacements = [
        {
          token = "font_family";
          value = font;
        }
      ];
    };

  xdgPlaceholders = [
    { path = "hypr/hyprlock.conf"; }
  ];

  links = [
    {
      name = "Hyprlock";
      target = ".config/hypr/hyprlock.conf";
      source = "hypr/hyprlock.conf";
    }
  ];
}
