{ config, themeLib }:

let
  enabled = config.programs.zed-editor.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/zed/themes" ];

  generate =
    { polarity }:
    let
      renderZedTheme =
        themePolarity: themeName:
        themeLib.renderTemplate {
          source = ./templates/zed-md3.json;
          target = "$out/zed/themes/monet-md3-${themePolarity}.json";
          polarity = themePolarity;
          colors = [
            "outline_variant"
            "primary"
            "surface_container_high"
            "surface_container"
            "surface"
            "surface_container_highest"
            "primary_container"
            "on_surface"
            "on_surface_variant"
            "surface_container_low"
            "tertiary"
            "outline"
            "surface_container_lowest"
            "error"
            "secondary"
            "secondary_container"
            "error_container"
            "tertiary_container"
          ];
          literalReplacements = [
            {
              token = "appearance";
              value = themePolarity;
            }
            {
              token = "theme_name";
              value = themeName;
            }
          ];
        };
    in
    ''
      ${renderZedTheme "light" "Monet MD3 Light"}
      ${renderZedTheme "dark" "Monet MD3 Dark"}
      jq -s '{
        "$schema": "https://zed.dev/schema/themes/v0.2.0.json",
        "name": "Monet MD3",
        "author": "matugen",
        "themes": (.[0].themes + .[1].themes)
      }' \
        "$out/zed/themes/monet-md3-light.json" \
        "$out/zed/themes/monet-md3-dark.json" \
        > "$out/zed/themes/monet-md3.json"
      rm "$out/zed/themes/monet-md3-light.json" "$out/zed/themes/monet-md3-dark.json"
    '';

  links = [
    {
      name = "Zed";
      target = ".config/zed/themes/monet-md3.json";
      source = "zed/themes/monet-md3.json";
    }
  ];
}
