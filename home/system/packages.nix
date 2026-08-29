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
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        # 剪贴板
        wl-clipboard
        cliphist

        # 系统工具
        libnotify
        brightnessctl
        usbutils
        impala
        sshfs
        adwaita-icon-theme
        wineWow64Packages.waylandFull
        winetricks

        # 压缩/归档
        ouch
        kdePackages.ark

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
