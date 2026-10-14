{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.vicinae;
in
{
  options.homeModules.vicinae = {
    enable = lib.mkEnableOption "Vicinae (neighborhood notification/status tool)";

    auto-start = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically start Vicinae on login";
    };

    use-layer-shell = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use layer shell protocol for window positioning";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional settings for Vicinae";
      example = {
        position = "top";
        height = 30;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = cfg.auto-start;
        environment = lib.mkIf cfg.use-layer-shell {
          USE_LAYER_SHELL = 1;
        };
      };
      settings = lib.recursiveUpdate {
        # 0.29 使用分模式主题配置；上游模块通过 VICINAE_OVERRIDES 保留用户可写设置。
        # 原生 icon_theme 使用 Monet 单色 SVG；扩展图片和绝对路径图标保留原色。
        theme.light.name = "monet-light";
        theme.light.icon_theme = "Monet-Vicinae-Light";
        theme.dark.name = "monet-dark";
        theme.dark.icon_theme = "Monet-Vicinae-Dark";
      } cfg.settings;

      package = pkgs.vicinae;
    };
  };
}
