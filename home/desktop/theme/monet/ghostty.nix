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

  # 每棵子树内置相对软链 monet-current → 本子树的模式文件：
  # 翻转 current 后自动解析到正确主题，无需运行时重写链接
  postSteps =
    { polarity }:
    ''
      ln -sfn "monet-${polarity}" "$out/ghostty/themes/monet-current"
    '';

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
    {
      name = "GhosttyCurrent";
      target = ".config/ghostty/themes/monet-current";
      source = "ghostty/themes/monet-current";
    }
  ];
}
