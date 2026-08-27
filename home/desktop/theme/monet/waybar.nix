{
  themeLib,
  waybarBodyCssPath,
}:

themeLib.mkColorApp {
  name = "Waybar";
  enable = true;
  template = ./templates/waybar-colors.css;
  themePath = "waybar/style.css";
  configPath = ".config/waybar/style.css";
  placeholder = true;
  placeholderText = "/* Managed by Monet theme activation */\n";
  postLink = themeLib.reloadScripts.waybar;
  # matugen 渲染 style.css 后追加 body 样式
  postSteps = _: ''
    cat ${themeLib.stablePath waybarBodyCssPath} >> "$out/waybar/style.css"
  '';
}
