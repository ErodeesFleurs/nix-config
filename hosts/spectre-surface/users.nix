{ pkgs, ... }:

{
  modules.system.users = {
    enable = true;
    defaultUser = {
      name = "fleurs";
      description = "Sanka...";
      shell = pkgs.nushell;
      hashedPassword = "$y$j9T$J9OIb1xLg.x2FQN6Mx04p1$SA.Nt.QpDSHN/.V6nIYQoctbBNtc7GZ1V7E3gYFus8D";
      extraGroups = [
        "wheel" # sudo 权限
        "networkmanager"
        "audio"
        "video"
        "input"
        "docker"
        "libvirtd"
      ];
    };
    enableUserborn = true;
    mutableUsers = false;
  };
}
