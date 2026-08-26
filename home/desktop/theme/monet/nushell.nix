{ config, themeLib }:

themeLib.mkColorApp {
  name = "Nushell";
  enable = config.programs.nushell.enable;
  template = ./templates/nushell.nu;
  themePath = "nushell/monet.nu";
  configPath = ".config/nushell/monet.nu";
  placeholder = true;
  placeholderText = ''
    # Managed by Monet theme activation
    $env.config.color_config = ($env.config.color_config | merge {})
  '';
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
}
