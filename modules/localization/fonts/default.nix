{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.localization.fonts;
in
{
  options.modules.localization.fonts = {
    enable = lib.mkEnableOption "字体模块";

    enable-default-packages = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "是否启用默认字体包集合（由 NixOS 的 fonts.defaultPackages 控制）";
    };

    font-dir = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "是否启用用户字体目录（fontDir），将字体复制到系统可用目录";
      };
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji

        font-awesome

        source-code-pro
        source-han-sans
        source-han-serif
        source-han-mono

        sarasa-gothic

        corefonts

        vista-fonts
        vista-fonts-cht
        vista-fonts-chs

        wqy_microhei
        wqy_zenhei

        nerd-fonts.caskaydia-cove
        nerd-fonts.caskaydia-mono
        nerd-fonts.symbols-only
        nerd-fonts.dejavu-sans-mono
      ];
      description = "要安装的字体包列表（使用 pkgs 命名空间内的包）";
    };

    # fontconfig 相关设置分组
    fontconfig = {
      enable = lib.mkEnableOption "是否启用并设置 fontconfig 默认字体配置以避免乱码";

      default-fonts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = {
          emoji = [
            "Noto Color Emoji"
          ];
          monospace = [
            "wqy-zenhei"
            "Noto Sans Mono CJK SC"
            "CaskaydiaCove NF"
            "Sarasa Mono SC"
            "DejaVu Sans Mono"
          ];
          sansSerif = [
            "wqy-zenhei"
            "Noto Sans CJK SC"
            "Source Han Sans SC"
            "DejaVu Sans"
          ];
          serif = [
            "wqy-zenhei"
            "Noto Serif CJK SC"
            "Source Han Serif SC"
            "DejaVu Serif"
          ];
        };
        description = "fontconfig 的默认字体映射（emoji / monospace / sansSerif / serif）";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 将配置应用到 NixOS 的 fonts 模块
    fonts = {
      enableDefaultPackages = cfg.enable-default-packages;
      fontDir = {
        enable = cfg.font-dir.enable;
      };
      packages = cfg.packages;
      fontconfig = {
        enable = cfg.fontconfig.enable;
        defaultFonts = cfg.fontconfig.default-fonts;
      };
    };
  };
}
