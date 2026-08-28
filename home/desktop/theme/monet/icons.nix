{
  lib,
  themeLib,
}:

let
  inherit (themeLib) currentSymlink homeDir;

  capitalize = mode: if mode == "dark" then "Dark" else "Light";

  folderAliases = [
    "folder-documents"
    "folder-download"
    "folder-downloads"
    "folder-music"
    "folder-open"
    "folder-pictures"
    "folder-publicshare"
    "folder-remote"
    "folder-saved-search"
    "folder-templates"
    "folder-videos"
    "inode-directory"
    "user-desktop"
    "user-home"
  ];

  # 各子树只含对应模式的主题（light 子树只有 Light 图标主题）
  mkThemeTemplates =
    mode:
    let
      themeName = "Monet-Papirus-${capitalize mode}";
    in
    [
      {
        name = "icons-${mode}-index";
        input = themeLib.materialize {
          source = ./templates/icon-theme.index;
          inherit mode;
          literals = {
            theme_name = themeName;
            base_theme = "Papirus-${capitalize mode}";
          };
        };
        output = "${mode}/icons/${themeName}/index.theme";
      }
      {
        name = "icons-${mode}-folder";
        input = themeLib.materialize {
          source = ./templates/folder.svg;
          inherit mode;
        };
        output = "${mode}/icons/${themeName}/scalable/places/folder.svg";
      }
    ];
in
themeLib.mkApp {
  enable = true;

  templates = lib.concatMap mkThemeTemplates [
    "light"
    "dark"
  ];

  # 常用目录别名软链（按子树执行）
  postSteps =
    { polarity }:
    let
      themeDir = "$out/icons/Monet-Papirus-${capitalize polarity}";
    in
    lib.concatMapStringsSep "\n" (name: ''
      ln -sfn folder.svg "${themeDir}/scalable/places/${name}.svg"
    '') folderAliases;

  activation.linkMonetIconThemes =
    lib.hm.dag.entryAfter
      [
        "initThemeLinks"
        "cleanupDarkmanLegacyHooks"
      ]
      ''
        ICON_DIR="${homeDir}/.local/share/icons"
        $DRY_RUN_CMD mkdir -p "$ICON_DIR"

        for theme in Monet-Papirus-Light Monet-Papirus-Dark; do
          $DRY_RUN_CMD ln -sfn "${currentSymlink}/icons/$theme" "$ICON_DIR/$theme"
        done
      '';
}
