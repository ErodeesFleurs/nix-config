{
  config,
  pkgs,
  inputs,
  ...
}:
let
  hyprland-packages = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
in
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
        common.default = [ "gtk" ];
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.portal.FileChooser" = "gtk";
          "org.freedesktop.portal.OpenURI" = "gtk";
        };
      };

      configPackages = [ ];

      extraPortals = with pkgs; [
        hyprland-packages.xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];

      xdgOpenUsePortal = true;
    };
  };
}
