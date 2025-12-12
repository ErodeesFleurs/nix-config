{ pkgs, ... }:

{
  # 用户账户配置
  users.users.sanka = {
    isNormalUser = true;
    description = "Sanka";
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
    hashedPassword = "$y$j9T$.dWghH0CwDQx.GdIlK1Nl/$rwo7rUUN7ffo1C6cVdavRpn56PgAZOV216ugv5EREt6";
  };
}
