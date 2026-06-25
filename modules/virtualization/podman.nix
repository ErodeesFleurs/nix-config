{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.virtualization.podman;
in
{
  options.modules.virtualization.podman = {
    enable = lib.mkEnableOption "Podman container runtime and related tools";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    users.users.fleurs = {
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];
    };

    environment.etc = {
      "subuid".text = "fleurs:100000:65536\n";
      "subgid".text = "fleurs:100000:65536\n";
    };

    environment.systemPackages = with pkgs; [
      podman-compose
    ];
  };
}
