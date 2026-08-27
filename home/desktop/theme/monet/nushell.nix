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
}
