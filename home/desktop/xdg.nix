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
        config.programs.ghostty.package
        config.programs.zed-editor.package
        pkgs.kdePackages.ark
        config.programs.firefox.package
      ];
    };
  };
}
