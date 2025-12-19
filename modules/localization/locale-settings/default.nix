{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.localization;
in
{
  options.modules.localization = {
    enable = lib.mkEnableOption "国际化与本地化设置";

    default-locale = lib.mkOption {
      type = lib.types.str;
      default = "zh_CN.UTF-8";
      description = "默认系统区域设置（locale）";
      example = "en_US.UTF-8";
    };

    supported-locales = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "zh_CN.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];
      description = "支持的区域设置列表（supported locales）";
    };

    extra-locale-settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "额外的区域设置（可为单独的 LC_* 变量指定不同的值）";
      example = {
        LC_TIME = "en_US.UTF-8";
        LC_MONETARY = "zh_CN.UTF-8";
      };
    };

    apply-to-all = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "将默认区域设置应用到所有 LC_* 变量（如果为 true，将为所有 LC_* 变量使用 default-locale）";
    };
  };

  config = lib.mkIf cfg.enable {
    # 设置默认 locale
    i18n.defaultLocale = cfg.default-locale;

    # 支持的 locale
    i18n.supportedLocales = cfg.supported-locales;

    # 额外的 locale 设置
    i18n.extraLocaleSettings =
      if cfg.apply-to-all then
        {
          LC_ADDRESS = cfg.default-locale;
          LC_IDENTIFICATION = cfg.default-locale;
          LC_MEASUREMENT = cfg.default-locale;
          LC_MONETARY = cfg.default-locale;
          LC_NAME = cfg.default-locale;
          LC_NUMERIC = cfg.default-locale;
          LC_PAPER = cfg.default-locale;
          LC_TELEPHONE = cfg.default-locale;
          LC_TIME = cfg.default-locale;
        }
        // cfg.extra-locale-settings
      else
        cfg.extra-locale-settings;
  };
}
