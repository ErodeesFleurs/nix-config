# Fleurs 用户配置（Spectre；共享配置在 ../common.nix）
{ pkgs, ... }:

{
  imports = [ ../common.nix ];

  home.packages = with pkgs; [
    rar
    go-musicfox
    aria2
  ];
}
