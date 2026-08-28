{
  config,
  lib,
  pkgs,
  themeLib,
}:

let
  font = config.homeModules.theme.fonts.sans-serif.name;
  inherit (themeLib) currentSymlink homeDir;
  iconSource = "${pkgs.fcitx5-material-color}/share/fcitx5-material-color";
  reloadClassicUi = themeLib.reloadScripts.fcitx5;

  capitalize = mode: if mode == "dark" then "Dark" else "Light";

  # 双显式模式渲染（theme.conf + 3 个 svg）× 2 主题目录 × 2 子树
  themeTemplates =
    lib.concatMap
      (
        subtree:
        lib.concatMap
          (
            mode:
            let
              themeName = "Monet${capitalize mode}";
              mkEntry = name: source: {
                name = "fcitx5-${mode}-${lib.removeSuffix ".conf" (lib.removeSuffix ".svg" name)}-${subtree}";
                input = themeLib.materialize {
                  inherit source mode;
                  literals.font = font;
                };
                output = "${subtree}/fcitx5/themes/${themeName}/${name}";
              };
            in
            [
              (mkEntry "theme.conf" ./templates/fcitx5-theme.conf)
              (mkEntry "panel.svg" ./templates/fcitx5-panel.svg)
              (mkEntry "panel-highlight.svg" ./templates/fcitx5-panel-highlight.svg)
              (mkEntry "menu-highlight.svg" ./templates/fcitx5-menu-highlight.svg)
            ]
          )
          [
            "light"
            "dark"
          ]
      )
      [
        "light"
        "dark"
      ];

  # svg → png 转换与图标拷贝（按子树执行，路径随 out 变量走）
  postStepsText =
    lib.concatMapStringsSep "\n"
      (
        mode:
        let
          themeDir = "$out/fcitx5/themes/Monet${capitalize mode}";
        in
        ''
          ${pkgs.librsvg}/bin/rsvg-convert --format png --output "${themeDir}/panel.png" "${themeDir}/panel.svg"
          ${pkgs.librsvg}/bin/rsvg-convert --format png --output "${themeDir}/panel-highlight.png" "${themeDir}/panel-highlight.svg"
          ${pkgs.librsvg}/bin/rsvg-convert --format png --output "${themeDir}/menu-highlight.png" "${themeDir}/menu-highlight.svg"
          cp ${iconSource}/arrow.png "${themeDir}/arrow.png"
          cp ${iconSource}/radio.png "${themeDir}/radio.png"
        ''
      )
      [
        "light"
        "dark"
      ];
in
themeLib.mkApp {
  enable = true;

  templates =
    # classicui.conf 按子树的 polarity 渲染（Theme=MonetLight/MonetDark）
    map
      (polarity: {
        name = "fcitx5-classicui-${polarity}";
        input = themeLib.materialize {
          source = ./templates/fcitx5-classicui.conf;
          mode = polarity;
          literals = {
            inherit font;
            theme = "Monet${capitalize polarity}";
          };
        };
        output = "${polarity}/fcitx5/conf/classicui.conf";
      })
      [
        "light"
        "dark"
      ]
    ++ themeTemplates;

  postSteps = _: postStepsText;

  xdgPlaceholders = [
    {
      path = "fcitx5/conf/classicui.conf";
      text = "# Managed by Monet theme activation\n";
    }
  ];

  links = [
    {
      name = "Fcitx5ClassicUi";
      activationName = "linkFcitx5ClassicUi";
      target = ".config/fcitx5/conf/classicui.conf";
      source = "fcitx5/conf/classicui.conf";
    }
  ];

  activation = {
    linkFcitx5Themes = lib.hm.dag.entryAfter [ "initThemeLinks" "cleanupDarkmanLegacyHooks" ] ''
      for MODE in Light Dark; do
        TARGET="${homeDir}/.local/share/fcitx5/themes/Monet$MODE"
        SOURCE="${currentSymlink}/fcitx5/themes/Monet$MODE"

        if [ -d "$SOURCE" ]; then
          $DRY_RUN_CMD mkdir -p "$(dirname "$TARGET")"
          $DRY_RUN_CMD ln -sfn "$SOURCE" "$TARGET"
        fi
      done
    '';

    reloadFcitx5Theme =
      lib.hm.dag.entryAfter
        [
          "linkFcitx5Themes"
          "linkFcitx5ClassicUi"
        ]
        ''
          ${reloadClassicUi}
        '';
  };
}
