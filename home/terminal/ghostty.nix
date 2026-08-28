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
      # 指向 monet-current 软链；darkman hook 切换该软链后由 USR2 触发 ghostty 重读
      theme = "monet-current";
      window-padding-x = 12;
      window-padding-y = 12;
      window-padding-balance = true;
      window-padding-color = "background";
    };
  };
}
