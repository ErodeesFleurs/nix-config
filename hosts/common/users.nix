# 用户账户（密码哈希在各 host 的 users.nix 中设置）
{ pkgs, ... }:

{
  users = {
    mutableUsers = false;

    users.fleurs = {
      isNormalUser = true;
      description = "Sanka...";
      shell = pkgs.nushell;
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "input"
        "docker"
        "libvirtd"
      ];
    };
  };

  services.userborn.enable = true;
}
