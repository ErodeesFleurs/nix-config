{ pkgs, ... }:

{
  # 输入法
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        kdePackages.fcitx5-qt
        qt6Packages.fcitx5-chinese-addons
        fcitx5-material-color
        fcitx5-pinyin-moegirl
        fcitx5-pinyin-zhwiki
      ];
    };
  };
}
