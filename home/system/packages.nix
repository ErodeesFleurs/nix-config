{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.homeModules.packages;
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
        # 上游桌面入口使用 PATH 中的 qq；显式指向包装器，避免绕过主题隔离。
        substitute ${upstream}/share/applications/qq.desktop "$out/share/applications/qq.desktop" \
          --replace-fail "Exec=qq %U" "Exec=$out/bin/qq %U"
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
        # 原生 deb 包及 Wayland/输入法选择由 nixpkgs 维护，不再调用其内部打包文件。
        wechat
        telegram-desktop
      ]
      ++ [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
  };
}
