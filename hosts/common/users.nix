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
        # netdev：允许非 root 使用 iwctl/impala 管理 iwd
        "netdev"
        "audio"
        "video"
        "input"
        "libvirtd"
      ];
    };
  };

  services.userborn.enable = true;
}
