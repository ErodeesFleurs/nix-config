{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.homeModules.packages;
  # nixpkgs 的 Linux 微信仍是 4.1.1.8；4.1.13 已内置原生 Wayland 后端。
  # 固定官方 AppImage 的哈希并沿用上游 FHS 打包，避免更新整套 nixpkgs。
  # Wayland 会话下自动选择原生后端；保留 DISPLAY 给小程序，不强制 Qt 后端。
  wechat = pkgs.callPackage "${pkgs.path}/pkgs/by-name/we/wechat/linux.nix" {
    pname = "wechat";
    version = "4.1.13.23";
    src = pkgs.fetchurl {
      name = "WeChatLinux_x86_64.AppImage";
      url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
      hash = "sha256-T1StKQLs1vb9xWgLc1R/gNVCO/RwsBI3pXmi5bPK7us=";
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

        # 压缩/归档（GUI 场景使用 Nautilus 内置归档功能，GVFS 提供挂载访问）
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
        (qq.override {
          commandLineArgs = [
            "--enable-wayland-ime"
            "--text-input-version=3"
          ];
        })
        wechat
        feishu
        telegram-desktop
      ]
      ++ [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
  };
}
