{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.variables;
in
{
  options.homeModules.variables = {
    enable = lib.mkEnableOption "custom session variables";

    browser = lib.mkOption {
      type = lib.types.str;
      default = "firefox";
      description = "Default browser";
    };

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "ghostty";
      description = "Default terminal emulator";
    };

    termType = lib.mkOption {
      type = lib.types.str;
      default = "xterm-256color";
      description = "Terminal type";
    };

    editor = lib.mkOption {
      type = lib.types.str;
      default = "hx";
      description = "Default editor";
    };

    fileManager = lib.mkOption {
      type = lib.types.str;
      default = "dolphin";
      description = "Default file manager";
    };

    wayland = {
      enableOzoneWayland = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Wayland support for Chromium/Electron apps";
      };

      disableHardwareCursors = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Disable hardware cursors (useful for some GPU/Wayland issues)";
      };

      sdlVideoDriver = lib.mkOption {
        type = lib.types.str;
        default = "wayland";
        description = "SDL video driver";
      };
    };

    extraVariables = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional session variables";
      example = {
        MY_CUSTOM_VAR = "value";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = lib.mkMerge [
      {
        # Default applications
        BROWSER = cfg.browser;
        TERMINAL = cfg.terminal;
        TERM = cfg.termType;
        EDITOR = cfg.editor;
        FILE_MANAGER = cfg.fileManager;
      }
      (lib.mkIf cfg.wayland.enableOzoneWayland {
        NIXOS_OZONE_WL = "1";
      })
      (lib.mkIf cfg.wayland.disableHardwareCursors {
        WLR_NO_HARDWARE_CURSORS = "1";
      })
      {
        SDL_VIDEODRIVER = cfg.wayland.sdlVideoDriver;
      }
      cfg.extraVariables
    ];
  };
}
