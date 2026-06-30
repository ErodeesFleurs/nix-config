{ config, themeLib }:

let
  enabled = config.programs.mpv.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/mpv" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/mpv.conf;
      target = "$out/mpv/monet.conf";
      inherit polarity;
      replacements = [
        {
          token = "surface_rgb";
          color = "surface";
          transform = "noHash";
        }
        {
          token = "on_surface_rgb";
          color = "on_surface";
          transform = "noHash";
        }
        {
          token = "surface_container_high_rgb";
          color = "surface_container_high";
          transform = "noHash";
        }
        {
          token = "outline_variant_rgb";
          color = "outline_variant";
          transform = "noHash";
        }
        {
          token = "primary_rgb";
          color = "primary";
          transform = "noHash";
        }
        {
          token = "primary_container_rgb";
          color = "primary_container";
          transform = "noHash";
        }
        {
          token = "inverse_on_surface_rgb";
          color = "inverse_on_surface";
          transform = "noHash";
        }
        {
          token = "inverse_surface_rgb";
          color = "inverse_surface";
          transform = "noHash";
        }
      ];
    };

  links = [
    {
      name = "Mpv";
      target = ".config/mpv/monet.conf";
      source = "mpv/monet.conf";
    }
  ];
}
