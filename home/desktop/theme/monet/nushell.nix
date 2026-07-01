{ config, themeLib }:

let
  enabled = config.programs.nushell.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/nushell" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/nushell.nu;
      target = "$out/nushell/monet.nu";
      inherit polarity;
      colors = [
        "surface_container_high"
        "on_surface"
        "on_surface_variant"
        "outline"
        "outline_variant"
        "primary"
        "primary_container"
        "on_primary_container"
        "secondary"
        "tertiary"
        "error_container"
        "on_error_container"
      ];
    };

  xdgPlaceholders = [
    {
      path = "nushell/monet.nu";
      text = ''
        # Managed by Monet theme activation
        $env.config.color_config = ($env.config.color_config | merge {})
      '';
    }
  ];

  links = [
    {
      name = "Nushell";
      target = ".config/nushell/monet.nu";
      source = "nushell/monet.nu";
    }
  ];
}
