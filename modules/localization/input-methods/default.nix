{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.localization.input-methods;
in
{
  options.modules.localization.input-methods = {
    enable = lib.mkEnableOption "输入法模块";

    type = lib.mkOption {
      type = lib.types.enum [
        "fcitx5"
      ];
      default = "fcitx5";
      description = "选择的输入法框架类型，例如 fcitx5（将来可添加 ibus）";
    };

    fcitx5 = {
      wayland-frontend = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "在 Wayland 上启用 fcitx5 前端";
      };

      addons = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          fcitx5-gtk
          kdePackages.fcitx5-qt
          qt6Packages.fcitx5-chinese-addons
          fcitx5-material-color
          fcitx5-pinyin-moegirl
          fcitx5-pinyin-zhwiki
        ];
        description = "fcitx5 附加包列表（使用 pkgs 命名空间中的包）";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = cfg.type;
      fcitx5 = {
        waylandFrontend = cfg.fcitx5.wayland-frontend;
        addons = cfg.fcitx5.addons;
      };
    };
  };
}
