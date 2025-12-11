{ pkgs, ... }:

{
  # 用户账户配置
  users.users.fleurs = {
    isNormalUser = true;
    description = "Fleurs";
    extraGroups = [
      "wheel" # sudo 权限
      "networkmanager"
      "audio"
      "video"
      "input"
      "docker"
      "libvirtd"
    ];
    shell = pkgs.nushell;
  };
}
