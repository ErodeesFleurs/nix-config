{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.hyprland;
in
{
  options.homeModules.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager user configuration";

    systemd = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable systemd integration";
    };

    xwayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable XWayland support";
    };

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "ghostty";
      description = "Default terminal emulator";
    };

    menu = lib.mkOption {
      type = lib.types.str;
      default = "vicinae toggle";
      description = "Application launcher command";
    };

    hyprlauncher = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable installing and using hyprlauncher as application launcher";
    };

    hyprpolkit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the hyprpolkitagent user systemd service";
    };

    browser = lib.mkOption {
      type = lib.types.str;
      default = "firefox";
      description = "Default web browser";
    };

    color-picker = lib.mkOption {
      type = lib.types.str;
      default = "hyprpicker -a";
      description = "Color picker command";
    };

    main-mod = lib.mkOption {
      type = lib.types.str;
      default = "SUPER";
      description = "Main modifier key";
    };

    environment = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_THEME,"
        "HYPRCURSOR_SIZE,24"
        "HYPRSHOT_DIR,$HOME/Pictures/Screenshots"
      ];
      description = "Environment variables";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ",preferred,auto,1" ];
      description = "Monitor configuration";
    };

    exec-once = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "systemctl --user import-environment XDG_SESSION_ID XDG_CURRENT_DESKTOP DBUS_SESSION_BUS_ADDRESS WAYLAND_DISPLAY DISPLAY"
        "hyprpaper"
        "hypridle"
        "swww-daemon"
        "dunst"
        "udiskie"
        "fcitx5 -d"
        "wl-paste --watch cliphist store"
        "lxqt-policykit-agent"
        "SSH_AUTH_SOCK=/run/user/1000/ssh-agent"
      ];
      description = "Commands to execute once on startup";
    };

    general = {
      gaps-in = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "Inner gaps size";
      };

      gaps-out = lib.mkOption {
        type = lib.types.int;
        default = 20;
        description = "Outer gaps size";
      };

      border-size = lib.mkOption {
        type = lib.types.int;
        default = 2;
        description = "Border size";
      };

      resize-on-border = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Resize windows on border";
      };

      allow-tearing = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Allow screen tearing";
      };

      layout = lib.mkOption {
        type = lib.types.str;
        default = "dwindle";
        description = "Window layout";
      };
    };

    decoration = {
      rounding = lib.mkOption {
        type = lib.types.int;
        default = 10;
        description = "Corner rounding";
      };

      active-opacity = lib.mkOption {
        type = lib.types.float;
        default = 1.0;
        description = "Active window opacity";
      };

      inactive-opacity = lib.mkOption {
        type = lib.types.float;
        default = 1.0;
        description = "Inactive window opacity";
      };

      blur = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable blur";
        };

        size = lib.mkOption {
          type = lib.types.int;
          default = 10;
          description = "Blur size";
        };

        passes = lib.mkOption {
          type = lib.types.int;
          default = 1;
          description = "Blur passes";
        };

        vibrancy = lib.mkOption {
          type = lib.types.float;
          default = 0.1696;
          description = "Blur vibrancy";
        };
      };
    };

    animations = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable animations";
      };
    };

    dwindle = {
      pseudotile = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable pseudotiling";
      };

      preserve-split = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Preserve split direction";
      };
    };

    input = {
      kb-layout = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "Keyboard layout";
      };

      follow-mouse = lib.mkOption {
        type = lib.types.int;
        default = 1;
        description = "Follow mouse mode";
      };

      sensitivity = lib.mkOption {
        type = lib.types.float;
        default = 0.0;
        description = "Mouse sensitivity";
      };

      touchpad = {
        natural-scroll = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable natural scrolling";
        };
      };
    };

    misc = {
      force-default-wallpaper = lib.mkOption {
        type = lib.types.int;
        default = 0;
        description = "Force default wallpaper (0 or 1)";
      };

      disable-hyprland-logo = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Disable Hyprland logo";
      };
    };

    extra-config = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional Hyprland configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = cfg.systemd;
      xwayland.enable = cfg.xwayland;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

      settings = lib.mkMerge [
        {
          env = cfg.environment;
          monitor = cfg.monitors;
          exec-once = cfg.exec-once;

          "$mainMod" = cfg.main-mod;
          "$terminal" = cfg.terminal;
          "$menu" = if cfg.hyprlauncher then "hyprlauncher" else cfg.menu;
          "$browser" = cfg.browser;
          "$colorpicker" = cfg.color-picker;

          general = {
            gaps_in = cfg.general.gaps-in;
            gaps_out = cfg.general.gaps-out;
            border_size = cfg.general.border-size;
            resize_on_border = cfg.general.resize-on-border;
            allow_tearing = cfg.general.allow-tearing;
            layout = cfg.general.layout;
          };

          decoration = {
            rounding = cfg.decoration.rounding;
            active_opacity = cfg.decoration.active-opacity;
            inactive_opacity = cfg.decoration.inactive-opacity;

            blur = {
              enabled = cfg.decoration.blur.enable;
              size = cfg.decoration.blur.size;
              passes = cfg.decoration.blur.passes;
              vibrancy = cfg.decoration.blur.vibrancy;
            };
          };

          animations = {
            enabled = if cfg.animations.enable then "yes" else "no";

            bezier = [
              "easeOutQuint,0.23,1,0.32,1"
              "easeInOutCubic,0.65,0.05,0.36,1"
              "linear,0,0,1,1"
              "almostLinear,0.5,0.5,0.75,1.0"
              "quick,0.15,0,0.1,1"
            ];

            animation = [
              "global, 1, 10, default"
              "border, 1, 5.39, easeOutQuint"
              "windows, 1, 4.79, easeOutQuint"
              "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
              "windowsOut, 1, 1.49, linear, popin 87%"
              "fadeIn, 1, 1.73, almostLinear"
              "fadeOut, 1, 1.46, almostLinear"
              "fade, 1, 3.03, quick"
              "layers, 1, 3.81, easeOutQuint"
              "layersIn, 1, 4, easeOutQuint, fade"
              "layersOut, 1, 1.5, linear, fade"
              "fadeLayersIn, 1, 1.79, almostLinear"
              "fadeLayersOut, 1, 1.39, almostLinear"
              "workspaces, 1, 1.94, almostLinear, fade"
              "workspacesIn, 1, 1.21, almostLinear, fade"
              "workspacesOut, 1, 1.94, almostLinear, fade"
            ];
          };

          dwindle = {
            pseudotile = cfg.dwindle.pseudotile;
            preserve_split = cfg.dwindle.preserve-split;
          };

          master = {
            new_status = "master";
          };

          misc = {
            force_default_wallpaper = cfg.misc.force-default-wallpaper;
            disable_hyprland_logo = cfg.misc.disable-hyprland-logo;
          };

          input = {
            kb_layout = cfg.input.kb-layout;
            kb_variant = "";
            kb_model = "";
            kb_options = "";
            kb_rules = "";

            follow_mouse = cfg.input.follow-mouse;
            sensitivity = cfg.input.sensitivity;

            touchpad = {
              natural_scroll = cfg.input.touchpad.natural-scroll;
            };
          };

          device = {
            name = "epic-mouse-v1";
            sensitivity = -0.5;
          };

          bind = [
            "$mainMod, T, exec, $terminal"
            "$mainMod, R, exec, $menu"
            "$mainMod, P, exec, $colorpicker"
            "$mainMod, C, killactive"
            "$mainMod, M, exit"
            "$mainMod, V, togglefloating"
            "$mainMod, P, pseudo"
            "$mainMod, J, togglesplit"

            # 截图
            ", PRINT, exec, hyprshot -m output"
            "$mainMod, PRINT, exec, hyprshot -m window"
            "$mainMod SHIFT, PRINT, exec, hyprshot -m region"

            # 使用 mainMod + 箭头键移动焦点
            "$mainMod, left, movefocus, l"
            "$mainMod, right, movefocus, r"
            "$mainMod, up, movefocus, u"
            "$mainMod, down, movefocus, d"

            # 工作区切换
            "$mainMod, 1, workspace, 1"
            "$mainMod, 2, workspace, 2"
            "$mainMod, 3, workspace, 3"
            "$mainMod, 4, workspace, 4"
            "$mainMod, 5, workspace, 5"
            "$mainMod, 6, workspace, 6"
            "$mainMod, 7, workspace, 7"
            "$mainMod, 8, workspace, 8"
            "$mainMod, 9, workspace, 9"
            "$mainMod, 0, workspace, 10"

            # 移动窗口到工作区
            "$mainMod SHIFT, 1, movetoworkspace, 1"
            "$mainMod SHIFT, 2, movetoworkspace, 2"
            "$mainMod SHIFT, 3, movetoworkspace, 3"
            "$mainMod SHIFT, 4, movetoworkspace, 4"
            "$mainMod SHIFT, 5, movetoworkspace, 5"
            "$mainMod SHIFT, 6, movetoworkspace, 6"
            "$mainMod SHIFT, 7, movetoworkspace, 7"
            "$mainMod SHIFT, 8, movetoworkspace, 8"
            "$mainMod SHIFT, 9, movetoworkspace, 9"
            "$mainMod SHIFT, 0, movetoworkspace, 10"

            # 特殊 workspace
            "$mainMod, S, togglespecialworkspace, magic"
            "$mainMod SHIFT, S, movetoworkspace, special:magic"

            # 使用 mainMod + scroll 滚动工作区
            "$mainMod, mouse_down, workspace, e+1"
            "$mainMod, mouse_up, workspace, e-1"
          ];

          bindm = [
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];

          bindel = [
            ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
            ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
            ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
          ];

          bindl = [
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPause, exec, playerctl play-pause"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioPrev, exec, playerctl previous"
          ];

          layerrule = [ ];

          windowrule = [
            "match:class .*, suppress_event maximize"
            "match:class ^$,match:title ^$, match:xwayland 1, float 1, fullscreen 0, pin 0"
            "match:class ^(wechat)$, match:title negative:^(朋友圈)$, border_size 1"
            "match:class ^(wechat)$, match:title negative:^(朋友圈)$, no_blur 1"
            "match:class ^(wechat)$, match:title negative:^(朋友圈)$, no_shadow 1"
          ];
        }
        cfg.extra-config
      ];
    };

    # If the user enabled hyprpolkit via this module, enable the global service.
    # This makes the module integrate with the system-level service option:
    # `services.hyprpolkitagent.enable = true`.
    services.hyprpolkitagent.enable = cfg.hyprpolkit;

    # Add hyprlauncher package when enabled
    home.packages = lib.concatLists [
      (lib.optional cfg.hyprlauncher [ pkgs.hyprlauncher ])
    ];
  };
}
