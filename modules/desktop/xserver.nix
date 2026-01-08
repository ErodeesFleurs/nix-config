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

    video-drivers = lib.mkOption {
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
        natural-scrolling = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable natural scrolling";
        };

        tapping = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable tap to click";
        };

        disable-while-typing = lib.mkOption {
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
      videoDrivers = cfg.video-drivers;
      xkb = {
        layout = cfg.layout;
        variant = cfg.variant;
      };
    };

    services.libinput = lib.mkIf cfg.libinput.enable {
      enable = true;
      touchpad = {
        naturalScrolling = cfg.libinput.touchpad.natural-scrolling;
        tapping = cfg.libinput.touchpad.tapping;
        disableWhileTyping = cfg.libinput.touchpad.disable-while-typing;
      };
    };
  };
}
