{
  config,
  lib,
  pkgs,
  themeLib,
}:

let
  enabled = config.programs.firefox.enable && config.homeModules.firefox.enable-monet;
  homeDir = config.home.homeDirectory;
  profileName = config.homeModules.firefox.profile-name;
  currentSymlink = "${homeDir}/.local/share/themes/current";
in
{
  enable = enabled;
  outputDirs = [ "$out/firefox" ];

  generate =
    { polarity }:
    ''
      ${themeLib.renderTemplate {
        source = ./templates/firefox-userChrome.css;
        target = "$out/firefox/userChrome.css";
        inherit polarity;
        colors = [
          "surface"
          "surface_container"
          "surface_container_high"
          "on_surface"
          "on_surface_variant"
          "outline_variant"
          "primary"
          "primary_container"
          "on_primary_container"
        ];
      }}

      ${themeLib.renderTemplate {
        source = ./templates/firefox-userContent.css;
        target = "$out/firefox/userContent.css";
        inherit polarity;
        colors = [
          "surface"
          "surface_container"
          "on_surface"
          "on_surface_variant"
          "primary"
        ];
      }}
    '';

  activation.linkFirefoxTheme =
    lib.hm.dag.entryAfter [ "initThemeLinks" "cleanupDarkmanLegacyHooks" ]
      ''
        PROFILES_INI="${homeDir}/.mozilla/firefox/profiles.ini"
        THEME_FIREFOX="${currentSymlink}/firefox"

        if [ -f "$PROFILES_INI" ] && [ -f "$THEME_FIREFOX/userChrome.css" ]; then
          PROFILE_PATH="$(
            ${pkgs.gawk}/bin/awk -v profile=${lib.escapeShellArg profileName} '
              /^\[Profile/ {
                if (name == profile && path != "") {
                  print path
                  found = 1
                  exit
                }
                name = ""
                path = ""
                next
              }
              /^Name=/ { name = substr($0, 6); next }
              /^Path=/ { path = substr($0, 6); next }
              END {
                if (!found && name == profile && path != "") {
                  print path
                }
              }
            ' "$PROFILES_INI"
          )"

          if [ -z "$PROFILE_PATH" ]; then
            PROFILE_PATH="$(
              ${pkgs.gawk}/bin/awk '
                /^\[Profile/ {
                  if (is_default == "1" && path != "") {
                    print path
                    found = 1
                    exit
                  }
                  is_default = ""
                  path = ""
                  next
                }
                /^Default=/ { is_default = substr($0, 9); next }
                /^Path=/ { path = substr($0, 6); next }
                END {
                  if (!found && is_default == "1" && path != "") {
                    print path
                  }
                }
              ' "$PROFILES_INI"
            )"
          fi

          if [ -n "$PROFILE_PATH" ]; then
            case "$PROFILE_PATH" in
              /*) PROFILE_DIR="$PROFILE_PATH" ;;
              *) PROFILE_DIR="${homeDir}/.mozilla/firefox/$PROFILE_PATH" ;;
            esac

            $DRY_RUN_CMD mkdir -p "$PROFILE_DIR/chrome"
            $DRY_RUN_CMD rm -f "$PROFILE_DIR/chrome/userChrome.css"
            $DRY_RUN_CMD rm -f "$PROFILE_DIR/chrome/userContent.css"
            $DRY_RUN_CMD ln -sfn "$THEME_FIREFOX/userChrome.css" "$PROFILE_DIR/chrome/userChrome.css"
            $DRY_RUN_CMD ln -sfn "$THEME_FIREFOX/userContent.css" "$PROFILE_DIR/chrome/userContent.css"

            USER_JS="$PROFILE_DIR/user.js"
            if [ -z "''${DRY_RUN_CMD:-}" ]; then
              TMP_USER_JS="$USER_JS.tmp"
              if [ -f "$USER_JS" ]; then
                ${pkgs.gnugrep}/bin/grep -v -E 'user_pref\("(toolkit\.legacyUserProfileCustomizations\.stylesheets|browser\.theme\.content-theme|browser\.theme\.toolbar-theme)"' "$USER_JS" > "$TMP_USER_JS" || true
              else
                : > "$TMP_USER_JS"
              fi

              printf '%s\n' \
                'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' \
                'user_pref("browser.theme.content-theme", 0);' \
                'user_pref("browser.theme.toolbar-theme", 0);' \
                >> "$TMP_USER_JS"

              mv "$TMP_USER_JS" "$USER_JS"
            else
              echo "would update Firefox user.js at $USER_JS"
            fi
          fi
        fi
      '';
}
