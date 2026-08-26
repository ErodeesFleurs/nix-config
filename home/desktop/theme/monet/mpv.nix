{ config, themeLib }:

let
  rgb = color: {
    token = "${color}_rgb";
    inherit color;
    transform = "noHash";
  };
in
themeLib.mkColorApp {
  name = "Mpv";
  enable = config.programs.mpv.enable;
  template = ./templates/mpv.conf;
  themePath = "mpv/monet.conf";
  configPath = ".config/mpv/monet.conf";
  replacements = map rgb [
    "surface"
    "on_surface"
    "surface_container_high"
    "outline_variant"
    "primary"
    "primary_container"
    "inverse_on_surface"
    "inverse_surface"
  ];
}
