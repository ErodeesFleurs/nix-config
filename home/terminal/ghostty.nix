{ config, lib, ... }:

{
  stylix.targets.ghostty.enable = lib.mkForce false;

  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      background-opacity = config.homeModules.stylix.opacity.terminal;
      font-family = [
        config.homeModules.stylix.fonts.monospace.name
        config.homeModules.stylix.fonts.emoji.name
      ];
      font-feature = "+liga,+calt,+dlig";
      font-size = 12;
      shell-integration-features = "ssh-terminfo,ssh-env";
      theme = "monet";
      window-padding-x = 12;
      window-padding-y = 12;
      window-padding-balance = true;
      window-padding-color = "background";
    };
  };
}
