{
  config,
  lib,
  pkgs,
  themeLib,
}:

let
  package = config.programs.vicinae.package;
  themeDir = "${themeLib.homeDir}/.local/share/vicinae/themes";
  theme = themeLib.mkColorApp {
    name = "Vicinae";
    enable = config.programs.vicinae.enable && package != null;
    template = ./templates/vicinae.toml;
    themePath = "vicinae/themes/monet.toml";
    configPath = null;
    literalsFor = polarity: { variant = polarity; };
    postSteps =
      { polarity }:
      let
        suffix = if polarity == "dark" then "Dark" else "Light";
      in
      ''
        ${pkgs.python3}/bin/python ${./vicinae-icons.py} \
          ${pkgs.papirus-icon-theme}/share/icons/Papirus \
          "$out/icons/Monet-Vicinae-${suffix}" "$out/vicinae/icon-palette.json"
      '';
  };
in
theme
// {
  # Native icon themes affect named application/file icons, not extension images
  # or absolute icon paths. Keep these separate from the desktop Papirus theme.
  templates =
    theme.templates
    ++
      map
        (polarity: {
          name = "vicinae-icons-${polarity}";
          input = themeLib.materialize {
            source = ./templates/vicinae-icon-palette.json;
            mode = polarity;
          };
          output = "${polarity}/vicinae/icon-palette.json";
        })
        [
          "light"
          "dark"
        ];
  # Vicinae 缓存已解析的主题，只监听主题目录；翻转目录外的 current 不会触发重读。
  # 两个固定 ID 分别绑定 light/dark 调色板，由系统外观信号选择，不写用户主题设置。
  activation.linkVicinaeTheme =
    lib.hm.dag.entryAfter
      [
        "linkGeneration"
        "initThemeLinks"
        "cleanupDarkmanLegacyHooks"
      ]
      ''
        $DRY_RUN_CMD mkdir -p "${themeDir}"
        for MODE in light dark; do
          TARGET="${themeDir}/monet-$MODE.toml"
          SOURCE="${themeLib.homeDir}/.local/share/themes/$MODE/vicinae/themes/monet.toml"
          $DRY_RUN_CMD ln -sfn "$SOURCE" "$TARGET.tmp"
          $DRY_RUN_CMD mv -T "$TARGET.tmp" "$TARGET"
        done
        ICON_DIR="${themeLib.homeDir}/.local/share/icons"
        $DRY_RUN_CMD mkdir -p "$ICON_DIR"
        for MODE in Light Dark; do
          if [ "$MODE" = Dark ]; then POLARITY=dark; else POLARITY=light; fi
          TARGET="$ICON_DIR/Monet-Vicinae-$MODE"
          SOURCE="${themeLib.homeDir}/.local/share/themes/$POLARITY/icons/Monet-Vicinae-$MODE"
          $DRY_RUN_CMD ln -sfn "$SOURCE" "$TARGET.tmp"
          $DRY_RUN_CMD mv -T "$TARGET.tmp" "$TARGET"
        done
        $DRY_RUN_CMD rm -f "${themeDir}/monet.toml"
      '';
}
