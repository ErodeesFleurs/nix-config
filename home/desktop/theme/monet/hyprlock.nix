{ config, lib }:

let
  enabled = config.programs.hyprlock.enable;
  homeDir = config.home.homeDirectory;
  currentSymlink = "${homeDir}/.local/share/themes/current";
  font = config.homeModules.theme.fonts.monospace.name;
in
{
  enable = enabled;
  outputDirs = [ "$out/hypr" ];

  generate =
    { polarity }:
    ''
      jq -r '
        def c($name): .colors[$name]["${polarity}"].color;
        def rgb($name): "rgb(" + (c($name) | ltrimstr("#")) + ")";
        def pango($name): "##" + (c($name) | ltrimstr("#"));
        [
          "general {",
          "  no_fade_in = false",
          "  no_fade_out = false",
          "  hide_cursor = true",
          "  grace = 0",
          "  disable_loading_bar = true",
          "  ignore_empty_input = true",
          "}",
          "",
          "input-field {",
          "  monitor =",
          "  size = 320, 64",
          "  outline_thickness = 2",
          "  dots_size = 0.22",
          "  dots_spacing = 0.35",
          "  dots_center = true",
          "  fade_on_empty = false",
          "  rounding = 24",
          "  outer_color = " + rgb("outline_variant"),
          "  inner_color = " + rgb("surface_container_high"),
          "  font_color = " + rgb("on_surface"),
          "  check_color = " + rgb("primary"),
          "  fail_color = " + rgb("error"),
          "  placeholder_text = <span foreground=\"" + pango("on_surface_variant") + "\">Password</span>",
          "  hide_input = false",
          "  position = 0, -200",
          "  halign = center",
          "  valign = center",
          "  fail_text = <span foreground=\"" + pango("error") + "\"><b>$ATTEMPTS</b></span>",
          "  fail_timeout = 2000",
          "  fail_transition = 300",
          "}",
          "",
          "label {",
          "  monitor =",
          "  text = cmd[update:1000] date +\"%A, %B %d\"",
          "  color = " + rgb("on_surface_variant"),
          "  font_size = 22",
          "  font_family = ${font}",
          "  position = 0, 300",
          "  halign = center",
          "  valign = center",
          "}",
          "",
          "label {",
          "  monitor =",
          "  text = cmd[update:1000] date +\"%-I:%M\"",
          "  color = " + rgb("on_surface"),
          "  font_size = 95",
          "  font_family = ${font}",
          "  position = 0, 200",
          "  halign = center",
          "  valign = center",
          "}"
        ] | .[]
      ' colors.json > "$out/hypr/hyprlock.conf"
    '';

  xdgConfig."hypr/hyprlock.conf" = {
    force = lib.mkForce true;
    text = "# Managed by Monet theme activation\n";
  };

  activation.linkHyprlockTheme =
    lib.hm.dag.entryAfter [ "initThemeLinks" "cleanupDarkmanLegacyHooks" ]
      ''
        HYPRLOCK_CONFIG="${homeDir}/.config/hypr/hyprlock.conf"
        THEME_HYPRLOCK="${currentSymlink}/hypr/hyprlock.conf"

        if [ -f "$THEME_HYPRLOCK" ]; then
          $DRY_RUN_CMD mkdir -p "$(dirname "$HYPRLOCK_CONFIG")"
          $DRY_RUN_CMD rm -f "$HYPRLOCK_CONFIG"
          $DRY_RUN_CMD ln -sfn "$THEME_HYPRLOCK" "$HYPRLOCK_CONFIG"
        fi
      '';
}
