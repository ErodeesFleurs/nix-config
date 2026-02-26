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
      defaultApplicationPackages = [
        config.homeModules.nemo.package
        config.programs.ghostty.package
        config.programs.zed-editor.package
        config.programs.firefox.package
        pkgs.kdePackages.ark
      ];
    };

    configFile = {
      "mimeapps.list".force = true;
      "uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
    };

    desktopEntries = {
      nemo = {
        name = "Nemo";
        exec = "${pkgs.nemo-with-extensions}/bin/nemo";
        icon = "${pkgs.nemo-with-extensions}/share/icons/hicolor/32x32/apps/nemo.png";
      };
    };

    portal = {
      enable = true;

      config = {
        common.default = [
          "gnome"
          "gtk"
        ];
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.portal.FileChooser" = "gtk";
          "org.freedesktop.portal.OpenURI" = "gtk";
        };
        niri = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };
      };

      configPackages = [ ];

      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];

      xdgOpenUsePortal = true;
    };
  };
}
