{ pkgs, ... }:

{
  modules.system.users = {
    enable = true;
    defaultUser = {
      name = "fleurs";
      description = "Sanka...";
      shell = pkgs.nushell;
      hashedPassword = "$y$j9T$YV/TCn7xlpXWTwFEjbxat1$VFr39Dgdn/za83M8y1Z4qUoK9YN5O9Hme3GHnlhf/DC";
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
