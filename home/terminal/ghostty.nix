{ config, lib, ... }:

let
  theme = config.homeModules.theme;
in
{
  stylix.targets.ghostty.enable = lib.mkForce false;

  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      background-opacity = theme.opacity.terminal;
      font-family = [
        theme.fonts.monospace.name
        theme.fonts.emoji.name
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
