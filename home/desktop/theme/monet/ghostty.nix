{
  config,
  lib,
  themeLib,
}:

themeLib.mkApp {
  enable = config.programs.ghostty.enable;

  # 单模板双显式模式渲染 × 两棵子树（翻转 current 后两棵子树都需要双主题文件）
  templates =
    lib.concatMap
      (
        subtree:
        map
          (mode: {
            name = "ghostty-${mode}-${subtree}";
            input = themeLib.materialize {
              source = ./templates/ghostty.theme;
              inherit mode;
            };
            output = "${subtree}/ghostty/themes/monet-${mode}";
          })
          [
            "light"
            "dark"
          ]
      )
      [
        "light"
        "dark"
      ];

  links = [
    {
      name = "GhosttyLight";
      target = ".config/ghostty/themes/monet-light";
      source = "ghostty/themes/monet-light";
    }
    {
      name = "GhosttyDark";
      target = ".config/ghostty/themes/monet-dark";
      source = "ghostty/themes/monet-dark";
    }
  ];
}
