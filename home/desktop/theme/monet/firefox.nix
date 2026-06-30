{
  config,
  lib,
  pkgs,
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
      jq -r '
        def c($name): .colors[$name]["${polarity}"].color;
        [
          ":root {",
          "  --m3-surface: " + c("surface") + ";",
          "  --m3-surface-container: " + c("surface_container") + ";",
          "  --m3-surface-container-high: " + c("surface_container_high") + ";",
          "  --m3-on-surface: " + c("on_surface") + ";",
          "  --m3-on-surface-variant: " + c("on_surface_variant") + ";",
          "  --m3-outline-variant: " + c("outline_variant") + ";",
          "  --m3-primary: " + c("primary") + ";",
          "  --m3-primary-container: " + c("primary_container") + ";",
          "  --m3-on-primary-container: " + c("on_primary_container") + ";",
          "}"
        ] | .[]
      ' colors.json > "$out/firefox/userChrome.css"

      cat >> "$out/firefox/userChrome.css" << 'CHROMECSS'

      #navigator-toolbox {
        background-color: var(--m3-surface-container) !important;
        border-bottom: 1px solid var(--m3-outline-variant) !important;
        color: var(--m3-on-surface) !important;
      }

      #TabsToolbar,
      #nav-bar,
      #PersonalToolbar {
        background-color: transparent !important;
        color: var(--m3-on-surface) !important;
      }

      #urlbar-background,
      #searchbar {
        background-color: var(--m3-surface-container-high) !important;
        border-color: var(--m3-outline-variant) !important;
        border-radius: 18px !important;
      }

      #urlbar[focused="true"] #urlbar-background {
        border-color: var(--m3-primary) !important;
        box-shadow: 0 0 0 1px var(--m3-primary) !important;
      }

      .tab-background {
        border-radius: 14px !important;
        margin-block: 4px !important;
      }

      .tabbrowser-tab[selected] .tab-background {
        background-color: var(--m3-primary-container) !important;
        color: var(--m3-on-primary-container) !important;
      }

      .tabbrowser-tab[selected] .tab-label {
        color: var(--m3-on-primary-container) !important;
      }

      toolbarbutton,
      .toolbarbutton-1 {
        color: var(--m3-on-surface-variant) !important;
      }

      toolbarbutton:hover,
      .toolbarbutton-1:hover {
        background-color: color-mix(in srgb, var(--m3-primary) 12%, transparent) !important;
        border-radius: 999px !important;
        color: var(--m3-on-surface) !important;
      }

      menupopup,
      panel {
        --panel-background: var(--m3-surface-container) !important;
        --panel-color: var(--m3-on-surface) !important;
        --panel-border-color: var(--m3-outline-variant) !important;
      }
      CHROMECSS

      jq -r '
        def c($name): .colors[$name]["${polarity}"].color;
        [
          ":root {",
          "  --m3-surface: " + c("surface") + ";",
          "  --m3-surface-container: " + c("surface_container") + ";",
          "  --m3-on-surface: " + c("on_surface") + ";",
          "  --m3-on-surface-variant: " + c("on_surface_variant") + ";",
          "  --m3-primary: " + c("primary") + ";",
          "}"
        ] | .[]
      ' colors.json > "$out/firefox/userContent.css"

      cat >> "$out/firefox/userContent.css" << 'CONTENTCSS'

      @-moz-document url("about:home"), url("about:newtab"), url("about:privatebrowsing") {
        body,
        .activity-stream {
          background: var(--m3-surface) !important;
          color: var(--m3-on-surface) !important;
        }

        .search-wrapper input,
        .fake-textbox {
          background: var(--m3-surface-container) !important;
          color: var(--m3-on-surface) !important;
          border-radius: 24px !important;
          border: 1px solid color-mix(in srgb, var(--m3-primary) 35%, transparent) !important;
        }

        .top-site-outer .tile {
          background: var(--m3-surface-container) !important;
          border-radius: 18px !important;
        }

        .section-title,
        .top-site-outer .title {
          color: var(--m3-on-surface-variant) !important;
        }
      }
      CONTENTCSS
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
