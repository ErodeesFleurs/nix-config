{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.hyprland;
in
{
  options.homeModules.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager user configuration";

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

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ",preferred,auto,1" ];
      description = "Monitor configuration";
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
      systemd.enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;

      settings = lib.mkMerge [
        {
          xwayland = "enable";

          env = [
            "LIBVA_DRIVER_NAME,nvidia"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
            "__GL_VRR_ALLOWED,0"

            "GTK_USE_PORTAL, 1"
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_TYPE,wayland"
            "XDG_SESSION_DESKTOP,Hyprland"

            "XCURSOR_SIZE,24"
            "HYPRCURSOR_THEME,"
            "HYPRCURSOR_SIZE,24"
            "HYPRSHOT_DIR,$XDG_CONFIG_HOME/Pictures/Screenshots"

            "SSH_AUTH_SOCK,/run/user/1000/ssh-agent"
          ];

          monitor = cfg.monitors;

          exec-once = [
            "udiskie"
            "fcitx5 -d"
            "wl-paste --watch cliphist store"
          ];

          "$mainMod" = cfg.main-mod;
          "$terminal" = cfg.terminal;
          "$menu" = cfg.menu;
          "$browser" = cfg.browser;
          "$colorpicker" = cfg.color-picker;

          general = {
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
            resize_on_border = false;
            allow_tearing = false;
            layout = "dwindle";
          };

          decoration = {
            rounding = 10;
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            blur = {
              enabled = true;
              size = 10;
              passes = 1;
              vibrancy = 0.1696;
            };
          };

          animations = {
            enabled = "yes";

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
            pseudotile = true;
            preserve_split = true;
          };

          master = {
            new_status = "master";
          };

          misc = {
            force_default_wallpaper = 0;
            disable_hyprland_logo = true;
          };

          input = {
            kb_layout = "us";
            kb_variant = "";
            kb_model = "";
            kb_options = "";
            kb_rules = "";

            follow_mouse = 1;
            sensitivity = 0.0;

            touchpad = {
              natural_scroll = false;
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

    services.hyprpolkitagent.enable = true;

    # Add hyprlauncher package when enabled
    home.packages = lib.concatLists [
      (lib.optional cfg.hyprlauncher [ pkgs.hyprlauncher ])
    ];
  };
}
