{
  lib,
  themeLib,
}:

let
  inherit (themeLib) currentSymlink homeDir;

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
in
themeLib.mkApp {
  enable = true;
  outputDirs = [ "$out/icons" ];

  generate =
    { polarity }:
    let
      themeName = if polarity == "dark" then "Monet-Papirus-Dark" else "Monet-Papirus-Light";
      baseTheme = if polarity == "dark" then "Papirus-Dark" else "Papirus-Light";
      themeDir = "$out/icons/${themeName}";
    in
    ''
      mkdir -p "${themeDir}/scalable/places"

      ${themeLib.renderTemplate {
        source = ./templates/icon-theme.index;
        target = "${themeDir}/index.theme";
        inherit polarity;
        literalReplacements = [
          {
            token = "theme_name";
            value = themeName;
          }
          {
            token = "base_theme";
            value = baseTheme;
          }
        ];
      }}

      ${themeLib.renderTemplate {
        source = ./templates/folder.svg;
        target = "${themeDir}/scalable/places/folder.svg";
        inherit polarity;
        colors = [
          "primary"
          "primary_container"
          "on_primary_container"
          "outline_variant"
        ];
      }}

      ${lib.concatMapStringsSep "\n" (name: ''
        ln -sfn folder.svg "${themeDir}/scalable/places/${name}.svg"
      '') folderAliases}
    '';

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
