{ pkgs, ... }:

{
  users = {
    mutableUsers = false;

    users = {
      fleurs = {
        isNormalUser = true;
        description = "Sanka...";
        shell = pkgs.nushell;
        hashedPassword = "$y$j9T$YV/TCn7xlpXWTwFEjbxat1$VFr39Dgdn/za83M8y1Z4qUoK9YN5O9Hme3GHnlhf/DC";
        extraGroups = [
          "wheel"
          "networkmanager"
          "audio"
          "video"
          "input"
          "docker"
          "libvirtd"
        ];
        autoSubUidGidRange = true;
      };
    };
  };

  services.userborn.enable = true;
}
