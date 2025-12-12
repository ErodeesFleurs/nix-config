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
    hashedPassword = "$y$j9T$J9OIb1xLg.x2FQN6Mx04p1$SA.Nt.QpDSHN/.V6nIYQoctbBNtc7GZ1V7E3gYFus8D";
  };
  users.mutableUsers = true;
}
