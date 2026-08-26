{
  config,
  lib,
  themeLib,
}:

let
  package = config.programs.vicinae.package;
  vicinae = lib.getExe package;
in
themeLib.mkColorApp {
  name = "Vicinae";
  enable = config.programs.vicinae.enable && package != null;
  template = ./templates/vicinae.toml;
  themePath = "vicinae/themes/monet.toml";
  configPath = ".local/share/vicinae/themes/monet.toml";
  colors = [
    "surface"
    "surface_container"
    "surface_container_high"
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
    "error"
  ];
  literalReplacementsFor = polarity: [
    {
      token = "variant";
      value = polarity;
    }
  ];
  postLink = ''
    ${vicinae} theme set monet >/dev/null 2>&1 || true
  '';
}
