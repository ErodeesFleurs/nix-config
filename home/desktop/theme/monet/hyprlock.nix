{ config, themeLib }:

let
  rgb = color: {
    token = "${color}_rgb";
    inherit color;
    transform = "noHash";
  };
in
themeLib.mkColorApp {
  name = "Hyprlock";
  enable = config.programs.hyprlock.enable;
  template = ./templates/hyprlock.conf;
  themePath = "hypr/hyprlock.conf";
  configPath = ".config/hypr/hyprlock.conf";
  placeholder = true;
  replacements = map rgb [
    "outline_variant"
    "surface_container_high"
    "on_surface"
    "primary"
    "error"
    "on_surface_variant"
  ];
  literalReplacements = [
    {
      token = "font_family";
      value = config.homeModules.theme.fonts.monospace.name;
    }
  ];
}
