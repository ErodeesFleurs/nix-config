{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.homeModules.packages;
in
{
  options.homeModules.packages = {
    enable = lib.mkEnableOption "user packages and utilities";

    hyprland-tools = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Hyprland ecosystem tools";
      };

      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          hyprpicker
          hyprsunset
          hyprcursor
          hyprshot
        ];
        description = "Hyprland-related packages";
      };
    };

    clipboard = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable clipboard management tools";
      };

      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          wl-clipboard
          cliphist
        ];
        description = "Clipboard management packages";
      };
    };

    system-utils = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable system utilities";
      };

      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          udiskie
          libnotify
          brightnessctl
          usbutils
          networkmanagerapplet
          sshfs
          sshpass
        ];
        description = "System utility packages";
      };
    };

    archive-tools = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable archive and compression tools";
      };

      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          unzip
          zip
          kdePackages.ark
        ];
        description = "Archive tool packages";
      };
    };

    media-tools = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable media processing tools";
      };

      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          ffmpeg
        ];
        description = "Media processing packages";
      };
    };

    communication = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable communication applications";
      };

      qq = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable QQ";
        };
      };

      wechat = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable WeChat";
        };
      };

      feishu = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Feishu (Lark)";
        };
      };

      telegram = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Telegram Desktop";
        };
      };

      dingtalk = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable DingTalk";
        };
      };
    };

    gaming = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable gaming applications";
      };

      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          osu-lazer-bin
        ];
        description = "Gaming packages";
      };
    };

    productivity = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable productivity applications";
      };

      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          # wpsoffice
          typora
          filezilla
          openvpn
          freerdp
        ];
        description = "Productivity packages";
      };
    };

    development = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable development and creative tools";
      };

      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          # aseprite
          steamcmd
          baidupcs-go
          blender
        ];
        description = "Development tool packages";
      };
    };

    theming = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable theming packages";
      };

      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          base16-schemes
        ];
        description = "Theming packages";
      };
    };

    agenix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable agenix (age-encrypted secrets)";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    home.packages =
      lib.optionals (cfg.hyprland-tools.enable) cfg.hyprland-tools.packages
      ++ lib.optionals (cfg.clipboard.enable) cfg.clipboard.packages
      ++ lib.optionals (cfg.system-utils.enable) cfg.system-utils.packages
      ++ lib.optionals (cfg.archive-tools.enable) cfg.archive-tools.packages
      ++ lib.optionals (cfg.media-tools.enable) cfg.media-tools.packages
      ++ lib.optionals (cfg.gaming.enable) cfg.gaming.packages
      ++ lib.optionals (cfg.productivity.enable) cfg.productivity.packages
      ++ lib.optionals (cfg.development.enable) cfg.development.packages
      ++ lib.optionals (cfg.theming.enable) cfg.theming.packages
      ++ lib.optionals (cfg.communication.enable && cfg.communication.qq.enable) [
        (pkgs.qq.override {
          commandLineArgs = [
            "--enable-wayland-ime"
            "--text-input-version=3"
          ];
        })
      ]
      ++ lib.optionals (cfg.communication.enable && cfg.communication.wechat.enable) [ pkgs.wechat ]
      ++ lib.optionals (cfg.communication.enable && cfg.communication.feishu.enable) [ pkgs.feishu ]
      ++ lib.optionals (cfg.communication.enable && cfg.communication.telegram.enable) [
        pkgs.telegram-desktop
      ]
      ++ lib.optionals (cfg.communication.enable && cfg.communication.dingtalk.enable) [
        inputs.xddxdd-nur.packages.${pkgs.stdenv.hostPlatform.system}.dingtalk
      ]
      ++ lib.optionals (cfg.agenix.enable) [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
  };
}
