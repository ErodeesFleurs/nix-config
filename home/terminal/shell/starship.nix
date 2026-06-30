{ config, lib, ... }:

{
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings.add_newline = true;
  };

  home.file.${config.programs.starship.configPath}.force = lib.mkForce true;
}
