{
  config,
  lib,
  themeLib,
}:

let
  capitalize = mode: if mode == "dark" then "Dark" else "Light";

  # 单主题对象片段（无 output_path，仅供主模板 include）
  mkObjInput =
    mode:
    themeLib.materialize {
      source = ./templates/zed-md3-theme.json;
      inherit mode;
      literals = {
        theme_name = "Monet MD3 ${capitalize mode}";
        appearance = mode;
      };
    };

  # 主模板：matugen include 原生拼装双模式主题族，无需 jq
  mainTemplate = builtins.toFile "zed-md3.matugen.json" ''
    {
      "$schema": "https://zed.dev/schema/themes/v0.2.0.json",
      "name": "Monet MD3",
      "author": "matugen",
      "themes": [
        <* include "zed-light-obj" *>,
        <* include "zed-dark-obj" *>
      ]
    }
  '';
in
themeLib.mkApp {
  enable = config.programs.zed-editor.enable;
  outputDirs = [ "$out/zed/themes" ];

  templates = [
    {
      name = "zed-light-obj";
      input = mkObjInput "light";
    }
    {
      name = "zed-dark-obj";
      input = mkObjInput "dark";
    }
    {
      name = "zed";
      input = mainTemplate;
      output = "zed/themes/monet-md3.json";
    }
  ];

  links = [
    {
      name = "Zed";
      target = ".config/zed/themes/monet-md3.json";
      source = "zed/themes/monet-md3.json";
    }
  ];
}
