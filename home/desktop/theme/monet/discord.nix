{ config, themeLib }:

# 生成的 monet.css 由 nixcord 经 current 软链 @import，无需创建链接
themeLib.mkColorApp {
  name = "Discord";
  enable = config.homeModules.discord.enable;
  template = ./templates/discord.css;
  themePath = "discord/monet.css";
  colors = [
    "surface"
    "surface_container_low"
    "surface_container"
    "surface_container_high"
    "surface_container_highest"
    "on_surface"
    "on_surface_variant"
    "outline"
    "outline_variant"
    "primary"
    "on_primary"
    "primary_container"
    "on_primary_container"
    "secondary"
    "secondary_container"
    "on_secondary_container"
    "tertiary"
    "tertiary_container"
    "on_tertiary_container"
    "error"
    "error_container"
    "on_error_container"
  ];
}
