{ pkgs, ... }:

{
  # Per-host user declarations (migrated from legacy `modules.user`).
  # Define users directly using the standard NixOS `users.users` and `users.mutableUsers`.
  users = {
    mutableUsers = false;

    users = {
      fleurs = {
        isNormalUser = true;
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
    };
  };

  services.userborn.enable = true;
}
