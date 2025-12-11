{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.terminal.yazi;
in
{
  options.homeModules.terminal.yazi = {
    enable = lib.mkEnableOption "Yazi file manager";

    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Nushell integration";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Zsh integration";
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Bash integration";
    };

    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Fish integration";
    };

    theme = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "Yazi theme configuration";
    };

    keymap = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "Custom keybindings";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Yazi configuration settings";
      example = {
        manager = {
          show_hidden = false;
          sort_by = "natural";
        };
      };
    };

    plugins = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Yazi plugins configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableNushellIntegration = cfg.enableNushellIntegration;
      enableZshIntegration = cfg.enableZshIntegration;
      enableBashIntegration = cfg.enableBashIntegration;
      enableFishIntegration = cfg.enableFishIntegration;

      theme = lib.mkIf (cfg.theme != null) cfg.theme;
      keymap = lib.mkIf (cfg.keymap != null) cfg.keymap;
      settings = cfg.settings;
      plugins = cfg.plugins;
    };
  };
}
