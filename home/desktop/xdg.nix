{ config, pkgs, ... }:

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
      };
    };
  };
}
