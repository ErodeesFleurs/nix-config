{ config, ... }:

let
  theme = config.homeModules.theme;
in
{
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
      # ghostty 原生双主题：跟随桌面明暗模式（由 darkman 的 gsettings color-scheme 驱动）
      theme = "light:monet-light,dark:monet-dark";
      window-padding-x = 12;
      window-padding-y = 12;
      window-padding-balance = true;
      window-padding-color = "background";
    };
  };
}
