{
  config,
  lib,
  pkgs,
  themeLib,
}:

let
  font = config.homeModules.theme.fonts.sans-serif.name;
  iconSource = "${pkgs.fcitx5-material-color}/share/fcitx5-material-color";
in
themeLib.mkApp {
  enable = true;
  outputDirs = [
    "$out/fcitx5/conf"
    "$out/fcitx5/themes/Monet"
  ];

  generate =
    { polarity }:
    ''
      ${themeLib.renderTemplate {
        source = ./templates/fcitx5-theme.conf;
        target = "$out/fcitx5/themes/Monet/theme.conf";
        inherit polarity;
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
        source = ./templates/fcitx5-classicui.conf;
        target = "$out/fcitx5/conf/classicui.conf";
        inherit polarity;
        literalReplacements = [
          {
            token = "font";
            value = font;
          }
        ];
      }}
      ${themeLib.renderTemplate {
        source = ./templates/fcitx5-panel.svg;
        target = "$out/fcitx5/themes/Monet/panel.svg";
        inherit polarity;
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
        target = "$out/fcitx5/themes/Monet/panel-highlight.svg";
        inherit polarity;
        colors = [ "primary_container" ];
      }}
      ${themeLib.renderTemplate {
        source = ./templates/fcitx5-menu-highlight.svg;
        target = "$out/fcitx5/themes/Monet/menu-highlight.svg";
        inherit polarity;
        colors = [ "primary_container" ];
      }}
      ${pkgs.librsvg}/bin/rsvg-convert --format png --output "$out/fcitx5/themes/Monet/panel.png" "$out/fcitx5/themes/Monet/panel.svg"
      ${pkgs.librsvg}/bin/rsvg-convert --format png --output "$out/fcitx5/themes/Monet/panel-highlight.png" "$out/fcitx5/themes/Monet/panel-highlight.svg"
      ${pkgs.librsvg}/bin/rsvg-convert --format png --output "$out/fcitx5/themes/Monet/menu-highlight.png" "$out/fcitx5/themes/Monet/menu-highlight.svg"
      cp ${iconSource}/arrow.png "$out/fcitx5/themes/Monet/arrow.png"
      cp ${iconSource}/radio.png "$out/fcitx5/themes/Monet/radio.png"
    '';

  xdgPlaceholders = [
    {
      path = "fcitx5/conf/classicui.conf";
      text = "# Managed by Monet theme activation\n";
    }
  ];

  links = [
    {
      name = "Fcitx5Theme";
      activationName = "linkFcitx5Theme";
      target = ".local/share/fcitx5/themes/Monet/theme.conf";
      source = "fcitx5/themes/Monet/theme.conf";
    }
    {
      name = "Fcitx5Arrow";
      activationName = "linkFcitx5Arrow";
      target = ".local/share/fcitx5/themes/Monet/arrow.png";
      source = "fcitx5/themes/Monet/arrow.png";
    }
    {
      name = "Fcitx5PanelImage";
      activationName = "linkFcitx5PanelImage";
      target = ".local/share/fcitx5/themes/Monet/panel.png";
      source = "fcitx5/themes/Monet/panel.png";
    }
    {
      name = "Fcitx5PanelHighlightImage";
      activationName = "linkFcitx5PanelHighlightImage";
      target = ".local/share/fcitx5/themes/Monet/panel-highlight.png";
      source = "fcitx5/themes/Monet/panel-highlight.png";
    }
    {
      name = "Fcitx5MenuHighlightImage";
      activationName = "linkFcitx5MenuHighlightImage";
      target = ".local/share/fcitx5/themes/Monet/menu-highlight.png";
      source = "fcitx5/themes/Monet/menu-highlight.png";
    }
    {
      name = "Fcitx5Radio";
      activationName = "linkFcitx5Radio";
      target = ".local/share/fcitx5/themes/Monet/radio.png";
      source = "fcitx5/themes/Monet/radio.png";
    }
    {
      name = "Fcitx5ClassicUi";
      activationName = "linkFcitx5ClassicUi";
      target = ".config/fcitx5/conf/classicui.conf";
      source = "fcitx5/conf/classicui.conf";
    }
  ];

  activation.reloadFcitx5Theme =
    lib.hm.dag.entryAfter
      [
        "linkFcitx5Theme"
        "linkFcitx5Arrow"
        "linkFcitx5PanelImage"
        "linkFcitx5PanelHighlightImage"
        "linkFcitx5MenuHighlightImage"
        "linkFcitx5Radio"
        "linkFcitx5ClassicUi"
      ]
      ''
        if command -v fcitx5-remote >/dev/null 2>&1; then
          fcitx5-remote -r >/dev/null 2>&1 || true
        fi
      '';
}
