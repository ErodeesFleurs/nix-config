{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeModules.krita;
  # 上游即使在 Wayland 会话中也默认选择 xcb；仅为 Krita 指定原生 Wayland，避免笔输入经 XWayland。
  krita = pkgs.krita.overrideAttrs (old: {
    qtWrapperArgs = (old.qtWrapperArgs or [ ]) ++ [
      "--set"
      "QT_QPA_PLATFORM"
      "wayland"
    ];
  });
  kritarc = "${config.xdg.configHome}/kritarc";
  # AutoSaveInterval 单位为秒；首次启动使用 5 分钟自动保存，并保留保存前的备份文件。
  defaults = pkgs.writeText "kritarc-defaults" ''
    [General]
    AutoSaveInterval=300
    CreateBackupFile=true
    touchPainting=2

    [theme]
    Theme=Krita dark
  '';
in
{
  options.homeModules.krita.enable = lib.mkEnableOption "Krita digital painting";

  config = lib.mkIf cfg.enable {
    home.packages = [ krita ];

    xdg.mimeApps.defaultApplications."application/x-krita" = "org.kde.krita.desktop";

    # Krita 6 touchPainting: 0=auto, 1=enabled, 2=disabled. 手指用于画布导航，笔用于绘画。
    # 仅初始化可写配置：后续在 GUI 中调整的压感、笔刷和快捷键不被 activation 覆盖。
    # Linux 的 System 主题仅有内部实现、无菜单入口；使用内置中性深色主题保持绘画环境稳定。
    home.activation.initKritaSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e ${lib.escapeShellArg kritarc} ]; then
        run ${pkgs.coreutils}/bin/install -Dm600 ${defaults} ${lib.escapeShellArg kritarc}
      fi
    '';
  };
}
