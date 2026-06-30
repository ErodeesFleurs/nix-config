{ config, themeLib }:

let
  enabled = config.programs.fastfetch.enable;
  inherit (themeLib) homeDir;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/fastfetch" ];

  generate =
    { polarity }:
    themeLib.renderTemplate {
      source = ./templates/fastfetch.jsonc;
      target = "$out/fastfetch/config.jsonc";
      inherit polarity;
      colors = [
        "primary"
        "tertiary"
      ];
      literalReplacements = [
        {
          placeholder = "home_dir";
          value = homeDir;
        }
      ];
    };

  links = [
    {
      name = "Fastfetch";
      target = ".config/fastfetch/config.jsonc";
      source = "fastfetch/config.jsonc";
    }
  ];
}
