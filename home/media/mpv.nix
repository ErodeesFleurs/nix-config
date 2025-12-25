{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.mpv;
in
{
  options.homeModules.mpv = {
    enable = lib.mkEnableOption "MPV media player";

    profile = lib.mkOption {
      type = lib.types.enum [
        "high-quality"
        "gpu-hq"
        "fast"
        "default"
      ];
      default = "gpu-hq";
      description = "Video quality profile";
    };

    hardware-acceleration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable hardware acceleration";
    };

    hwdec-method = lib.mkOption {
      type = lib.types.str;
      default = "auto-safe";
      description = "Hardware decoding method";
      example = "vaapi";
    };

    save-position = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Save playback position on quit";
    };

    volume = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "Default volume (0-100)";
    };

    volume-max = lib.mkOption {
      type = lib.types.int;
      default = 200;
      description = "Maximum volume (0-1000)";
    };

    screenshot = {
      format = lib.mkOption {
        type = lib.types.enum [
          "png"
          "jpg"
          "jpeg"
          "webp"
        ];
        default = "png";
        description = "Screenshot format";
      };

      template = lib.mkOption {
        type = lib.types.str;
        default = "~/Pictures/Screenshots/mpv-%F-%P";
        description = "Screenshot filename template";
      };

      quality = lib.mkOption {
        type = lib.types.int;
        default = 90;
        description = "Screenshot quality (0-100, for JPEG/WebP)";
      };
    };

    osd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable on-screen display";
      };

      font-size = lib.mkOption {
        type = lib.types.int;
        default = 32;
        description = "OSD font size";
      };

      duration = lib.mkOption {
        type = lib.types.int;
        default = 2000;
        description = "OSD duration in milliseconds";
      };
    };

    ytdl-format = lib.mkOption {
      type = lib.types.str;
      default = "bestvideo[height<=?1080]+bestaudio/best";
      description = "YouTube-DL format string";
    };

    scripts = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "MPV scripts to install";
      example = lib.literalExpression "[ pkgs.mpvScripts.mpris ]";
    };

    bindings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Custom key bindings";
      example = {
        "WHEEL_UP" = "seek 10";
        "WHEEL_DOWN" = "seek -10";
      };
    };

    extra-options = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Additional MPV configuration options";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;

      scripts = cfg.scripts;

      bindings = cfg.bindings;

      config = lib.mkMerge [
        {
          # Video quality
          profile = cfg.profile;

          # Hardware acceleration
          hwdec = lib.mkIf cfg.hardware-acceleration cfg.hwdec-method;
          vo = lib.mkIf cfg.hardware-acceleration "gpu";

          # Playback
          save-position-on-quit = cfg.save-position;

          # Audio
          volume = cfg.volume;
          volume-max = cfg.volume-max;

          # Screenshots
          screenshot-format = cfg.screenshot.format;
          screenshot-template = cfg.screenshot.template;
          screenshot-jpeg-quality = lib.mkIf (
            cfg.screenshot.format == "jpeg" || cfg.screenshot.format == "jpg"
          ) cfg.screenshot.quality;
          screenshot-webp-quality = lib.mkIf (cfg.screenshot.format == "webp") cfg.screenshot.quality;
          screenshot-png-compression = lib.mkIf (cfg.screenshot.format == "png") 7;

          # OSD
          osd-font-size = cfg.osd.font-size;
          osd-duration = cfg.osd.duration;
          osd-bar = cfg.osd.enable;

          # YouTube-DL
          ytdl-format = cfg.ytdl-format;

          # Additional settings
          keep-open = true;
          cursor-autohide = 1000;
        }
        cfg.extra-options
      ];
    };
  };
}
