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
    enable = cfg.enable;
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    environment.systemPackages = with pkgs; [
      podman-compose
    ];
  };
}
