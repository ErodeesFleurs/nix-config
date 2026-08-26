# 两台主机的共享配置入口
{ ... }:

{
  imports = [
    ./boot.nix
    ./desktop.nix
    ./hardware.nix
    ./locale.nix
    ./network.nix
    ./nix.nix
    ./programs.nix
    ./security.nix
    ./users.nix
  ];

  # /etc overlay（不可变）+ nixos-init + 派生 machine-id
  modules.etc = {
    enable = true;
    overlay-mutable = false;
  };

  # tuigreet 登录界面（monet 主题由 modules.desktop.theme 生成）
  modules.display-manager.tuigreet.enable = true;
}
