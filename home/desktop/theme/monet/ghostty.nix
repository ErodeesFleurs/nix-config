{ config, lib }:

let
  enabled = config.programs.ghostty.enable;
  homeDir = config.home.homeDirectory;
  currentSymlink = "${homeDir}/.local/share/themes/current";
in
{
  enable = enabled;
  outputDirs = [ "$out/ghostty/themes" ];

  generate =
    { polarity }:
    ''
      jq -r '
        def c($name): .colors[$name]["${polarity}"].color;
        [
          "background = " + c("surface"),
          "foreground = " + c("on_surface"),
          "cursor-color = " + c("primary"),
          "cursor-text = " + c("on_primary"),
          "selection-background = " + c("primary_container"),
          "selection-foreground = " + c("on_primary_container"),
          "palette = 0=" + c("surface_container"),
          "palette = 1=" + c("error"),
          "palette = 2=" + c("tertiary"),
          "palette = 3=" + c("primary"),
          "palette = 4=" + c("secondary"),
          "palette = 5=" + c("primary"),
          "palette = 6=" + c("tertiary"),
          "palette = 7=" + c("on_surface"),
          "palette = 8=" + c("outline"),
          "palette = 9=" + c("error"),
          "palette = 10=" + c("tertiary"),
          "palette = 11=" + c("primary"),
          "palette = 12=" + c("secondary"),
          "palette = 13=" + c("primary"),
          "palette = 14=" + c("tertiary"),
          "palette = 15=" + c("inverse_surface")
        ] | .[]
      ' colors.json > "$out/ghostty/themes/monet"
    '';

  activation.linkGhosttyTheme =
    lib.hm.dag.entryAfter [ "initThemeLinks" "cleanupDarkmanLegacyHooks" ]
      ''
        GHOSTTY_THEME="${homeDir}/.config/ghostty/themes/monet"
        THEME_GHOSTTY="${currentSymlink}/ghostty/themes/monet"

        if [ -f "$THEME_GHOSTTY" ]; then
          $DRY_RUN_CMD mkdir -p "$(dirname "$GHOSTTY_THEME")"
          $DRY_RUN_CMD rm -f "$GHOSTTY_THEME"
          $DRY_RUN_CMD ln -sfn "$THEME_GHOSTTY" "$GHOSTTY_THEME"
        fi
      '';
}
