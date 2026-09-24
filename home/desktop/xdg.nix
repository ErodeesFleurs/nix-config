{
  config,
  pkgs,
  ...
}:
{
  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
    };

    mimeApps = {
      enable = true;
      # Prefer dedicated image/document viewers to browser MIME associations.
      defaultApplicationPackages = [
        pkgs.loupe
        pkgs.papers
        config.homeModules.nautilus.package
        config.programs.ghostty.package
        config.programs.zed-editor.package
        config.programs.firefox.package
      ];
    };

    configFile = {
      "mimeapps.list".force = true;
    };

    portal = {
      enable = true;

      config = {
        common.default = [
          "gnome"
          "gtk"
        ];
        niri = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
          # GNOME delegates to Nautilus's GTK4 chooser, sharing its live Monet palette.
          "org.freedesktop.impl.portal.FileChooser" = "gnome";
          "org.freedesktop.impl.portal.Secret" = "oo7";
        };
      };

      configPackages = [ ];

      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
        oo7-portal
      ];

      xdgOpenUsePortal = true;
    };
  };
}
