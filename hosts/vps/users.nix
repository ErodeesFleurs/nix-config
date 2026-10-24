{ config, lib, ... }:
{
  imports = [
    ../common/users.nix
  ];

  # Debian's retained daemon group owns GID 1, NixOS's usual wheel GID.
  users.groups.wheel.gid = lib.mkForce 1001;

  # Reuse the desktop's immutable account, password and Nushell conventions,
  # but do not grant a server account desktop-device or VM-management groups.
  users.users.fleurs = {
    uid = 1000;
    extraGroups = lib.mkForce [ "wheel" ];
    hashedPassword = "$y$j9T$J9OIb1xLg.x2FQN6Mx04p1$SA.Nt.QpDSHN/.V6nIYQoctbBNtc7GZ1V7E3gYFus8D";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICXZT5BZTeDTgIk2oEOiZwjtrSLwlnD6tCla410rGut"
    ];
  };

  age.secrets.vps-root-password = {
    file = ../../secrets/vps/root-password.age;
    path = "/etc/nixos-secrets/root-password-hash";
    mode = "0600";
  };
  users.users.root = {
    hashedPasswordFile = config.age.secrets.vps-root-password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvb93FRr1GI3AwH3P0endhZ82g/bxG+/KYQBNM+/Yya openstarbound-remote-builder"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOu0mw6NNUXavOeEEBCvW9wiFkZBWQN6kmDXgYrfy/52 openstarbound-builder"
    ];
  };

  security.sudo.enable = false;
  security.sudo-rs = {
    enable = true;
    wheelNeedsPassword = true;
  };
}
