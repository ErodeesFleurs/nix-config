{
  config,
  lib,
  themeLib,
}:

let
  inherit (themeLib) currentSymlink homeDir;
in
themeLib.mkApp {
  enable = config.programs.ghostty.enable;
  outputDirs = [ "$out/ghostty/themes" ];

  # 单模板双显式模式渲染（两份输入仅在 mode 上不同）
  templates =
    map
      (mode: {
        name = "ghostty-${mode}";
        input = themeLib.materialize {
          source = ./templates/ghostty.theme;
          inherit mode;
        };
        output = "ghostty/themes/monet-${mode}";
      })
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

  activation.linkGhosttyCurrentTheme =
    lib.hm.dag.entryAfter
      [
        "linkGhosttyLightTheme"
        "linkGhosttyDarkTheme"
      ]
      ''
        MODE="$(readlink ${currentSymlink} 2>/dev/null || printf light)"
        case "$MODE" in
          dark|light) ;;
          *) MODE=light ;;
        esac

        TARGET="${homeDir}/.config/ghostty/themes/monet-current"
        SOURCE="${currentSymlink}/ghostty/themes/monet-$MODE"

        if [ -f "$SOURCE" ]; then
          $DRY_RUN_CMD mkdir -p "$(dirname "$TARGET")"
          $DRY_RUN_CMD ln -sfn "$SOURCE" "$TARGET"
        fi
      '';
}
