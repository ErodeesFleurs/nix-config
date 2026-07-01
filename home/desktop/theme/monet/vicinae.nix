{
  config,
  lib,
  themeLib,
}:

let
  package = config.programs.vicinae.package;
  enabled = config.programs.vicinae.enable && package != null;
  vicinae = lib.getExe package;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/vicinae/themes" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/vicinae.toml;
      target = "$out/vicinae/themes/monet.toml";
      inherit polarity;
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
      literalReplacements = [
        {
          token = "variant";
          value = polarity;
        }
      ];
    };

  links = [
    {
      name = "Vicinae";
      target = ".local/share/vicinae/themes/monet.toml";
      source = "vicinae/themes/monet.toml";
      postLink = ''
        ${vicinae} theme set monet >/dev/null 2>&1 || true
      '';
    }
  ];
}
