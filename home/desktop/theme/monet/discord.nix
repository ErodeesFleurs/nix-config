{ config, themeLib }:

# 生成的 monet.css 由 nixcord 经 current 软链 @import，无需创建链接
themeLib.mkColorApp {
  name = "Discord";
  enable = config.homeModules.discord.enable;
  template = ./templates/discord.css;
  themePath = "discord/monet.css";
}
