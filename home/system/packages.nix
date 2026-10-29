{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.homeModules.packages;
  # 官方 AppImage 滚动地址会原地换包；更新哈希时需核对主程序版本并同步 version。
  # 固定官方 AppImage 的哈希并沿用上游 FHS 打包，避免更新整套 nixpkgs。
  # Wayland 会话下自动选择原生后端；保留 DISPLAY 给小程序，不强制 Qt 后端。
  wechat = pkgs.callPackage "${pkgs.path}/pkgs/by-name/we/wechat/linux.nix" {
    pname = "wechat";
    version = "4.1.13.26";
    src = pkgs.fetchurl {
      name = "WeChatLinux_x86_64.AppImage";
      url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
      hash = "sha256-RSYYC8qYASh5FZmvEi/0eVACpXFaUQ9qZUgOK+aHQkQ=";
    };
    meta = pkgs.wechat.meta;
    # 在 FHS 构造阶段设置 profile，仅微信的原生 Wayland 启用内置 v3 输入插件。
    # 外层 overrideAttrs.profile 不会重建 /etc/profile；X11 启动保持原有输入法设置。
    appimageTools = pkgs.appimageTools // {
      wrapAppImage =
        args:
        pkgs.appimageTools.wrapAppImage (
          args
          // {
            profile = (args.profile or "") + ''
              if [[ -n "''${WAYLAND_DISPLAY:-}" && "''${QT_QPA_PLATFORM:-}" != xcb* ]]; then
                export QT_IM_MODULE=text-input-unstable-v3
              fi
            '';
          }
        );
    };
  };
  # QQ / Electron 40 用 GTK3 背景色判断模式；GTK3 缓存的 Monet 用户样式会覆盖 portal。
  # 仅在 QQ 的挂载视图中隔离静态 CSS/设置，保留系统主题信号、账号路径与原生 Wayland。
  # GTK3 配置是符号链接，需挂载到解析后的文件；这不是安全沙箱，不隔离用户数据。
  qq =
    let
      upstream = pkgs.qq.override {
        commandLineArgs = [
          "--enable-wayland-ime"
          "--text-input-version=3"
        ];
      };
      emptyGtkConfig = pkgs.writeText "qq-gtk-config-empty" "";
      emptyGtkSettings = pkgs.writeText "qq-gtk-settings-empty" "[Settings]\n";
      launcher = pkgs.writeShellScript "qq-system-theme" ''
        set -euo pipefail
        gtk_config="''${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0"
        mounts=()
        for file in gtk.css settings.ini; do
          if [[ -f "$gtk_config/$file" ]]; then
            source=${emptyGtkConfig}
            if [[ "$file" == settings.ini ]]; then
              source=${emptyGtkSettings}
            fi
            target=$(${pkgs.coreutils}/bin/readlink -e "$gtk_config/$file")
            mounts+=(--ro-bind "$source" "$target")
          fi
        done
        exec ${lib.getExe pkgs.bubblewrap} \
          --bind / / --dev-bind /dev /dev --bind /proc /proc \
          "''${mounts[@]}" -- ${upstream}/bin/qq "$@"
      '';
    in
    pkgs.symlinkJoin {
      name = "${upstream.name}-system-theme";
      inherit (upstream) pname version meta;
      paths = [ upstream ];
      postBuild = ''
        ln -sfn ${launcher} "$out/bin/qq"
        rm "$out/share/applications/qq.desktop"
        substitute ${upstream}/share/applications/qq.desktop "$out/share/applications/qq.desktop" \
          --replace-fail "${upstream}/bin/qq" "$out/bin/qq"
      '';
    };
in
{
  options.homeModules.packages = {
    enable = lib.mkEnableOption "user packages and utilities";
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        # 剪贴板
        wl-clipboard

        # 系统工具
        libnotify
        brightnessctl
        usbutils
        impala
        sshfs
        adwaita-icon-theme
        wineWow64Packages.waylandFull
        winetricks

        # 压缩/归档：File Roller 提供图形浏览与选择性解压，ouch 用于命令行。
        file-roller
        ouch

        # 媒体处理
        ffmpeg
        pwvucontrol

        # 游戏
        osu-lazer-bin

        # 生产力
        freerdp

        # 开发
        steamcmd
        baidupcs-go

        # 通讯
        qq
        wechat
        telegram-desktop
      ]
      ++ [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
  };
}
