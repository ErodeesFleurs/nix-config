{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeModules.libreoffice;
in
{
  options.homeModules.libreoffice.enable = lib.mkEnableOption "LibreOffice with GTK theme integration";

  config = lib.mkIf cfg.enable {
    programs.libreoffice = {
      enable = true;
      # Limit the backend override to Office; GTK3 reads the existing Monet palette.
      package = pkgs.libreoffice.override {
        extraMakeWrapperArgs = [
          "--set"
          "SAL_USE_VCLPLUGIN"
          "gtk3"
        ];
      };
      # Keep the writable user profile: HM settings forcibly replaces it on activation.
      # Appearance defaults to Automatic; do not pin a separate application palette.
    };

    # Associate editable Office formats only; PDF remains with Papers.
    xdg.mimeApps.defaultApplications =
      lib.genAttrs [
        "application/msword"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/vnd.oasis.opendocument.text"
        "application/rtf"
      ] (_: "writer.desktop")
      // lib.genAttrs [
        "application/vnd.ms-excel"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        "application/vnd.oasis.opendocument.spreadsheet"
        "text/csv"
      ] (_: "calc.desktop")
      // lib.genAttrs [
        "application/vnd.ms-powerpoint"
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        "application/vnd.oasis.opendocument.presentation"
      ] (_: "impress.desktop")
      // {
        "application/vnd.oasis.opendocument.graphics" = "draw.desktop";
      };
  };
}
