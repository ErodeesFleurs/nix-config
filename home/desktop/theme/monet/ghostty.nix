{
  config,
  lib,
  themeLib,
}:

let
  enabled = config.programs.ghostty.enable;
  inherit (themeLib) currentSymlink homeDir;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/ghostty/themes" ];

  generate =
    { polarity }:
    let
      renderGhosttyTheme =
        themePolarity:
        themeLib.renderTemplate {
          source = ./templates/ghostty.theme;
          target = "$out/ghostty/themes/monet-${themePolarity}";
          polarity = themePolarity;
          colors = themeLib.mergeColorTokens [
            themeLib.terminalColorTokens
            [
              "surface_container_high"
              "on_primary"
              "primary_container"
              "tertiary_container"
              "outline_variant"
            ]
          ];
        };
    in
    ''
      ${renderGhosttyTheme "light"}
      ${renderGhosttyTheme "dark"}
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
