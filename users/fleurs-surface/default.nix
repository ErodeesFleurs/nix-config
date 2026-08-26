# Fleurs 用户配置（Spectre Surface；共享配置在 ../common.nix）
{ pkgs, ... }:

{
  imports = [ ../common.nix ];

  home.packages = with pkgs; [
    rar
    go-musicfox
  ];

  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
}
