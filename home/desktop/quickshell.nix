{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeModules.desktop.quickshell;
  themeLib = import ./theme/monet/lib.nix { inherit config lib pkgs; };
  wechat = lib.findFirst (package: lib.getName package == "wechat") null config.home.packages;
  trayArtwork =
    lib.optionalAttrs config.programs.vicinae.enable {
      vicinae = "${config.programs.vicinae.package}/share/icons/hicolor/512x512/apps/vicinae.png";
    }
    // lib.optionalAttrs (wechat != null) {
      wechat = "${wechat}/share/icons/hicolor/256x256/apps/wechat.png";
    };
  # Native backgrounds are opaque: an alpha-only tint loses both logos.
  # Extract their white artwork at build time, leaving transparent negative space;
  # QML then applies the live Monet foreground without recoloring backgrounds.
  trayIcons = lib.mapAttrs (
    name: source:
    "${pkgs.runCommand "quickshell-${name}-symbolic.png" { nativeBuildInputs = [ pkgs.imagemagick ]; }
      ''
        magick ${source} -channel A -fx 'a * max(0,min(1,(min(r,min(g,b))-0.8)*5))' \
          -channel RGB -fill white -colorize 100 +channel -resize 128x128 "$out"
      ''
    }"
  ) trayArtwork;
  status = pkgs.writeShellApplication {
    name = "quickshell-status";
    runtimeInputs = [
      pkgs.python3
      pkgs.iw
    ];
    text = ''exec python3 ${themeLib.stablePath ./quickshell/status.py} "$@"'';
  };
  settings = pkgs.writeText "quickshell-settings.json" (
    builtins.toJSON {
      inherit (cfg) touch barHeight;
      inherit trayIcons;
      fontFamily = config.homeModules.theme.fonts.monospace.name;
      keyboardEnabled = cfg.keyboard.enable;
      keyboardUnit = cfg.keyboard.unit;
      palettePath = "${config.home.homeDirectory}/.local/share/themes/current/quickshell/palette.json";
      commands = {
        niri = [ (lib.getExe config.programs.niri.package) ];
        darkman = [ "${pkgs.darkman}/bin/darkman" ];
        launcher = [
          "vicinae"
          "toggle"
        ];
        network = [
          "${pkgs.ghostty}/bin/ghostty"
          "-e"
          "${pkgs.impala}/bin/impala"
        ];
        audioMixer = [ "${pkgs.pwvucontrol}/bin/pwvucontrol" ];
        monitor = [
          "${pkgs.ghostty}/bin/ghostty"
          "-e"
          "${pkgs.btop}/bin/btop"
        ];
        keyboardToggle = cfg.keyboard.toggleCommand;
        status = [ (lib.getExe status) ];
        brightness = [ "${pkgs.brightnessctl}/bin/brightnessctl" ];
        powerprofiles = [ "${pkgs.power-profiles-daemon}/bin/powerprofilesctl" ];
        systemctl = [ "${pkgs.systemd}/bin/systemctl" ];
        lock = [
          "${pkgs.systemd}/bin/loginctl"
          "lock-session"
        ];
      };
    }
  );
  sourceFiles = lib.filterAttrs (
    name: type: type == "regular" && (lib.hasSuffix ".qml" name || name == "qmldir")
  ) (builtins.readDir ./quickshell);
  shellConfig = pkgs.linkFarm "quickshell-fleurs" (
    lib.mapAttrsToList (name: _: {
      inherit name;
      path = themeLib.stablePath (./quickshell + "/${name}");
    }) sourceFiles
    ++ [
      {
        name = "settings.json";
        path = settings;
      }
    ]
  );
in
{
  options.homeModules.desktop.quickshell = {
    enable = lib.mkEnableOption "shared Niri Quickshell bar with a scrollable full application tray, live Monet-themed menus (right-click or long-press), and control center with live power-profiles-daemon modes, independently of idle inhibition";
    touch = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use larger touch hitboxes without stretching the centered icon/label group; Surface enables this, the laptop uses compact controls.";
    };
    barHeight = lib.mkOption {
      type = lib.types.ints.positive;
      default = if cfg.touch then 48 else 40;
      description = "Bar height in logical pixels, independently of the Niri output scale.";
    };
    keyboard = {
      enable = lib.mkEnableOption "manual on-screen keyboard button";
      unit = lib.mkOption {
        type = lib.types.str;
        default = "surface-keyboard.service";
        description = "User service monitored by the keyboard button; never auto-claims the input-method seat.";
      };
      toggleCommand = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Argument vector for the existing keyboard toggle, shared with the Niri shortcut.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.homeModules.desktop.darkman.enable;
        message = "The shared Quickshell configuration requires darkman's central light/dark palette.";
      }
      {
        assertion = !cfg.keyboard.enable || cfg.keyboard.toggleCommand != [ ];
        message = "Quickshell's keyboard button requires a real toggleCommand.";
      }
    ];

    # Only the bar/panel is replaced: Vicinae, Mako, hypridle, hyprlock and
    # iwd/networkd keep their existing ownership. No compositor startup duplicate.
    programs.quickshell = {
      enable = true;
      activeConfig = "fleurs";
      configs.fleurs = shellConfig;
      systemd.enable = true;
    };
    systemd.user.services.quickshell = {
      Unit = {
        PartOf = [ config.wayland.systemd.target ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
        X-Restart-Triggers = [ "${shellConfig}" ];
      };
      Service = {
        Slice = "app-graphical.slice";
        # Qt's portal theme does not select the GTK icon theme in this session.
        # Monet's mode-specific overlay exists only in its active subtree.
        # Tray shapes use its installed Papirus base; live foreground supplies color.
        Environment = [ "QS_ICON_THEME=Papirus" ];
      };
    };
    # Re-linking a generated palette does not necessarily change the shell unit.
    # Refresh a running instance after HM updates the theme tree, without restart.
    home.activation.reloadQuickshellPalette = lib.hm.dag.entryAfter [
      "linkGeneration"
      "initThemeLinks"
    ] themeLib.reloadScripts.quickshell;
  };
}
