{ pkgs, ... }:

{
  # Per-host user declarations (migrated from legacy `modules.user`).
  # Define users directly using the standard NixOS `users` namespace.
  users = {
    mutableUsers = false;

    users = {
      fleurs = {
        isNormalUser = true;
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
    };
  };

  services.userborn.enable = true;
}
