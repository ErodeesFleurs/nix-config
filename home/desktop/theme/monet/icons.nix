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
        output = "icons/${themeName}/index.theme";
      }
      {
        name = "icons-${mode}-folder";
        input = themeLib.materialize {
          source = ./templates/folder.svg;
          inherit mode;
        };
        output = "icons/${themeName}/scalable/places/folder.svg";
      }
    ];
in
themeLib.mkApp {
  enable = true;
  # 输出目录由 matugen 自行创建；本应用按 polarity 只渲染对应主题
  outputDirs = [ ];

  templates = { polarity }: mkThemeTemplates polarity;

  # 常用目录别名软链（按 polarity 只对当次主题目录操作）
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
