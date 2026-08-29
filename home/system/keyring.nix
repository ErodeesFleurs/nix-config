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
  # 注意 nixpkgs 拆分：oo7 只是 CLI，守护进程在 oo7-server，
  # 解锁提示 UI/Secret portal 在 oo7-portal（首次解锁密钥环需要）。
  config = lib.mkIf cfg.enable {
    # niri-flake 的 HM 模块无条件开启 services.gnome-keyring，强制关闭
    services.gnome-keyring.enable = lib.mkForce false;

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
