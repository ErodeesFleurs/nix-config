{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.i18n;
in
{
  options.modules.i18n = {
    enable = lib.mkEnableOption "Internationalization and localization";

    defaultLocale = lib.mkOption {
      type = lib.types.str;
      default = "zh_CN.UTF-8";
      description = "Default system locale";
      example = "en_US.UTF-8";
    };

    supportedLocales = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "zh_CN.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];
      description = "List of supported locales";
    };

    extraLocaleSettings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional locale settings";
      example = {
        LC_TIME = "en_US.UTF-8";
        LC_MONETARY = "zh_CN.UTF-8";
      };
    };

    applyToAll = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply default locale to all LC_* variables";
    };
  };

  config = lib.mkIf cfg.enable {
    # 设置默认 locale
    i18n.defaultLocale = cfg.defaultLocale;

    # 支持的 locale
    i18n.supportedLocales = cfg.supportedLocales;

    # 额外的 locale 设置
    i18n.extraLocaleSettings =
      if cfg.applyToAll then
        {
          LC_ADDRESS = cfg.defaultLocale;
          LC_IDENTIFICATION = cfg.defaultLocale;
          LC_MEASUREMENT = cfg.defaultLocale;
          LC_MONETARY = cfg.defaultLocale;
          LC_NAME = cfg.defaultLocale;
          LC_NUMERIC = cfg.defaultLocale;
          LC_PAPER = cfg.defaultLocale;
          LC_TELEPHONE = cfg.defaultLocale;
          LC_TIME = cfg.defaultLocale;
        }
        // cfg.extraLocaleSettings
      else
        cfg.extraLocaleSettings;
  };
}
