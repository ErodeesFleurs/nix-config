{
  pkgs,
  themeLib,
  waybarBodyCssPath,
}:

themeLib.mkApp {
  enable = true;
  outputDirs = [ "$out/waybar" ];

  generate =
    { polarity }:
    ''
      jq -r '
        def c($name): .colors[$name]["${polarity}"].color;
        [
          "@define-color m3_surface " + c("surface") + ";",
          "@define-color m3_surface_container " + c("surface_container") + ";",
          "@define-color m3_surface_container_high " + c("surface_container_high") + ";",
          "@define-color m3_on_surface " + c("on_surface") + ";",
          "@define-color m3_on_surface_variant " + c("on_surface_variant") + ";",
          "@define-color m3_outline " + c("outline") + ";",
          "@define-color m3_primary " + c("primary") + ";",
          "@define-color m3_on_primary " + c("on_primary") + ";",
          "@define-color m3_primary_container " + c("primary_container") + ";",
          "@define-color m3_on_primary_container " + c("on_primary_container") + ";",
          "@define-color m3_secondary_container " + c("secondary_container") + ";",
          "@define-color m3_on_secondary_container " + c("on_secondary_container") + ";",
          "@define-color m3_tertiary_container " + c("error_container") + ";",
          "@define-color m3_on_tertiary_container " + c("on_error_container") + ";",
          "@define-color m3_warning_container " + c("primary_container") + ";",
          "@define-color m3_on_warning_container " + c("on_primary_container") + ";",
          ""
        ] | .[]
      ' colors.json > "$out/waybar/style.css"

      cat ${waybarBodyCssPath} >> "$out/waybar/style.css"
    '';

  xdgPlaceholders = [
    {
      path = "waybar/style.css";
      text = "/* Managed by Monet theme activation */\n";
    }
  ];

  links = [
    {
      name = "Waybar";
      target = ".config/waybar/style.css";
      source = "waybar/style.css";
      postLink = ''
        ${pkgs.procps}/bin/pkill -SIGUSR2 waybar 2>/dev/null || true
      '';
    }
  ];
}
