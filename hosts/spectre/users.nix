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
    hashedPassword = "$y$j9T$YV/TCn7xlpXWTwFEjbxat1$VFr39Dgdn/za83M8y1Z4qUoK9YN5O9Hme3GHnlhf/DC";
  };
}
