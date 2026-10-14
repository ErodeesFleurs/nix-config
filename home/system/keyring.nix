{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.keyring;
in
{
  options.homeModules.keyring = {
    enable = lib.mkEnableOption "oo7 Secret Service daemon (credential storage)";
  };

  # oo7：GNOME 官方的 Rust 密钥环实现，取代 gnome-keyring-daemon。
  # 只提供 org.freedesktop.secrets（pkcs11/ssh 组件本未使用：
  # SSH_AUTH_SOCK 指向 systemd 的 ssh-agent socket）。
  # nixpkgs 拆分：oo7-server 提供守护进程，oo7-portal 提供 Secret portal；
  # 密钥环解锁窗口另由 gcr_3 的 SystemPrompter 提供（gcr_4 不包含它）。
  config = lib.mkIf cfg.enable {
    # niri-flake 的 HM 模块无条件开启 services.gnome-keyring，强制关闭
    services.gnome-keyring.enable = lib.mkForce false;

    # Zed 等客户端会先等待密钥环解锁，再打开认证网页。仅启动 oo7
    # 而不注册 SystemPrompter，会让这个等待无法完成。
    xdg.dataFile."dbus-1/services/org.gnome.keyring.SystemPrompter.service".source =
      "${pkgs.gcr_3}/share/dbus-1/services/org.gnome.keyring.SystemPrompter.service";

    systemd.user.services = {
      oo7-daemon = {
        Unit = {
          Description = "oo7 Secret Service daemon";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.oo7-server}/libexec/oo7-daemon";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
      oo7-portal = {
        Unit = {
          Description = "oo7 Secret portal backend";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.oo7-portal}/libexec/oo7-portal";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
