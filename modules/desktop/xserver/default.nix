{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.xserver;
in
{
  options.modules.xserver = {
    enable = lib.mkEnableOption "X Server";

    videoDrivers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Video drivers to use";
    };

    layout = lib.mkOption {
      type = lib.types.str;
      default = "us";
      description = "Keyboard layout";
    };

    variant = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Keyboard variant";
    };

    libinput = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable libinput for input devices";
      };

      touchpad = {
        naturalScrolling = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable natural scrolling";
        };

        tapping = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable tap to click";
        };

        disableWhileTyping = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Disable touchpad while typing";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      videoDrivers = cfg.videoDrivers;
      xkb = {
        layout = cfg.layout;
        variant = cfg.variant;
      };
    };

    services.libinput = lib.mkIf cfg.libinput.enable {
      enable = true;
      touchpad = {
        naturalScrolling = cfg.libinput.touchpad.naturalScrolling;
        tapping = cfg.libinput.touchpad.tapping;
        disableWhileTyping = cfg.libinput.touchpad.disableWhileTyping;
      };
    };
  };
}
