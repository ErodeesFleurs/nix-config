{
  config,
  lib,
  pkgs,
  themeLib,
}:

let
  font = config.homeModules.theme.fonts.sans-serif.name;
  inherit (themeLib) currentSymlink homeDir;
  iconSource = "${pkgs.fcitx5-material-color}/share/fcitx5-material-color";
  fcitx5Remote = "${pkgs.fcitx5}/bin/fcitx5-remote";
  reloadClassicUi = ''
    ${pkgs.glib}/bin/gdbus call \
      --session \
      --dest org.fcitx.Fcitx5 \
      --object-path /controller \
      --method org.fcitx.Fcitx.Controller1.ReloadAddonConfig \
      classicui >/dev/null 2>&1 \
      || ${fcitx5Remote} -r >/dev/null 2>&1 \
      || true
  '';
in
themeLib.mkApp {
  enable = true;
  outputDirs = [
    "$out/fcitx5/conf"
    "$out/fcitx5/themes/MonetLight"
    "$out/fcitx5/themes/MonetDark"
  ];

  generate =
    { polarity }:
    let
      activeTheme = if polarity == "dark" then "MonetDark" else "MonetLight";
      renderFcitxTheme = themePolarity: themeName: ''
        ${themeLib.renderTemplate {
          source = ./templates/fcitx5-theme.conf;
          target = "$out/fcitx5/themes/${themeName}/theme.conf";
          polarity = themePolarity;
          colors = [
            "surface_container_high"
            "on_surface"
            "primary_container"
            "on_primary_container"
            "outline"
            "outline_variant"
          ];
          literalReplacements = [
            {
              token = "font";
              value = font;
            }
          ];
        }}
        ${themeLib.renderTemplate {
          source = ./templates/fcitx5-panel.svg;
          target = "$out/fcitx5/themes/${themeName}/panel.svg";
          polarity = themePolarity;
          replacements = [
            "surface_container_high"
            "outline_variant"
            {
              token = "shadow";
              color = "shadow";
            }
          ];
        }}
        ${themeLib.renderTemplate {
          source = ./templates/fcitx5-panel-highlight.svg;
          target = "$out/fcitx5/themes/${themeName}/panel-highlight.svg";
          polarity = themePolarity;
          colors = [ "primary_container" ];
        }}
        ${themeLib.renderTemplate {
          source = ./templates/fcitx5-menu-highlight.svg;
          target = "$out/fcitx5/themes/${themeName}/menu-highlight.svg";
          polarity = themePolarity;
          colors = [ "primary_container" ];
        }}
        ${pkgs.librsvg}/bin/rsvg-convert --format png --output "$out/fcitx5/themes/${themeName}/panel.png" "$out/fcitx5/themes/${themeName}/panel.svg"
        ${pkgs.librsvg}/bin/rsvg-convert --format png --output "$out/fcitx5/themes/${themeName}/panel-highlight.png" "$out/fcitx5/themes/${themeName}/panel-highlight.svg"
        ${pkgs.librsvg}/bin/rsvg-convert --format png --output "$out/fcitx5/themes/${themeName}/menu-highlight.png" "$out/fcitx5/themes/${themeName}/menu-highlight.svg"
        cp ${iconSource}/arrow.png "$out/fcitx5/themes/${themeName}/arrow.png"
        cp ${iconSource}/radio.png "$out/fcitx5/themes/${themeName}/radio.png"
      '';
    in
    ''
      ${themeLib.renderTemplate {
        source = ./templates/fcitx5-classicui.conf;
        target = "$out/fcitx5/conf/classicui.conf";
        inherit polarity;
        literalReplacements = [
          {
            token = "font";
            value = font;
          }
          {
            token = "theme";
            value = activeTheme;
          }
        ];
      }}
      ${renderFcitxTheme "light" "MonetLight"}
      ${renderFcitxTheme "dark" "MonetDark"}
    '';

  xdgPlaceholders = [
    {
      path = "fcitx5/conf/classicui.conf";
      text = "# Managed by Monet theme activation\n";
    }
  ];

  links = [
    {
      name = "Fcitx5ClassicUi";
      activationName = "linkFcitx5ClassicUi";
      target = ".config/fcitx5/conf/classicui.conf";
      source = "fcitx5/conf/classicui.conf";
    }
  ];

  activation = {
    linkFcitx5Themes = lib.hm.dag.entryAfter [ "initThemeLinks" "cleanupDarkmanLegacyHooks" ] ''
      for MODE in Light Dark; do
        TARGET="${homeDir}/.local/share/fcitx5/themes/Monet$MODE"
        SOURCE="${currentSymlink}/fcitx5/themes/Monet$MODE"

        if [ -d "$SOURCE" ]; then
          $DRY_RUN_CMD mkdir -p "$(dirname "$TARGET")"
          $DRY_RUN_CMD ln -sfn "$SOURCE" "$TARGET"
        fi
      done
    '';

    reloadFcitx5Theme =
      lib.hm.dag.entryAfter
        [
          "linkFcitx5Themes"
          "linkFcitx5ClassicUi"
        ]
        ''
          ${reloadClassicUi}
        '';
  };
}
