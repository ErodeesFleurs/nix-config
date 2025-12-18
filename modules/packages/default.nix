{ pkgs, ... }:

/*
  nix-config/modules/packages/default.nix
  Packages aggregator — 全局软件包列表聚合

  CN: 本文件用于集中声明系统级别常用软件包与少量 programs 配置。模板保持与其它模块头部风格一致，
      并直接在此处声明常用包与必要的 program 开关。
  EN: Central place for system-wide packages and minimal program toggles. The header style is kept consistent with other modules.
*/

{
  environment.systemPackages = with pkgs; [
    lshw
    nixfmt-rfc-style
    hyprpolkitagent
    lxqt.lxqt-policykit
    xdg-utils
  ];

  programs.nix-ld.enable = true;
}
