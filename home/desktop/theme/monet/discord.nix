{ config, themeLib }:

# Nixcord 直接加载完整主题；媒体查询跟随系统明暗，不依赖 current 软链重读。
themeLib.mkColorApp {
  name = "Discord";
  enable = config.homeModules.discord.enable;
  template = ./templates/discord.css;
  themePath = "discord/palette.css";
  literalsFor = polarity: { mode = polarity; };
  postSteps =
    { polarity }:
    if polarity == "light" then
      ''
        # 两棵壁纸色板均已生成；与 GTK4 一样嵌入两种模式，支持运行时切换。
        {
          cat "$out/discord/palette.css"
          echo '@media (prefers-color-scheme: dark) {'
          cat "$out/../dark/discord/palette.css"
          echo '}'
        } > "$out/discord/monet.css"
        cp "$out/discord/monet.css" "$out/../dark/discord/monet.css"
        rm "$out/discord/palette.css" "$out/../dark/discord/palette.css"
      ''
    else
      "";
}
