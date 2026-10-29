{
  config,
  lib,
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
      # Prefer dedicated image/document/archive viewers to browser MIME associations.
      defaultApplicationPackages = [
        pkgs.loupe
        pkgs.papers
        pkgs.file-roller
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
          # 跟随 darkman 的 appearance 信号；GNOME 在 niri 下可能只返回“无偏好”。
          # 保留 GNOME/GTK 后端，以提供 darkman 不实现的光标等设置。
          "org.freedesktop.impl.portal.Settings" = lib.optional config.services.darkman.enable "darkman" ++ [
            "gnome"
            "gtk"
          ];
        };
      };

      configPackages = [ ];

      extraPortals =
        (with pkgs; [
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
          oo7-portal
        ])
        ++ lib.optional config.services.darkman.enable config.services.darkman.package;

      xdgOpenUsePortal = true;
    };
  };
}
