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
          placeholder = "surface_rgb";
          color = "surface";
          transform = "noHash";
        }
        {
          placeholder = "on_surface_rgb";
          color = "on_surface";
          transform = "noHash";
        }
        {
          placeholder = "surface_container_high_rgb";
          color = "surface_container_high";
          transform = "noHash";
        }
        {
          placeholder = "outline_variant_rgb";
          color = "outline_variant";
          transform = "noHash";
        }
        {
          placeholder = "primary_rgb";
          color = "primary";
          transform = "noHash";
        }
        {
          placeholder = "primary_container_rgb";
          color = "primary_container";
          transform = "noHash";
        }
        {
          placeholder = "inverse_on_surface_rgb";
          color = "inverse_on_surface";
          transform = "noHash";
        }
        {
          placeholder = "inverse_surface_rgb";
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
