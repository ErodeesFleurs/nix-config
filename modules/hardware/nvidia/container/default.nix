{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.hardware.nvidia-container;
in
{
  options.modules.hardware.nvidia-container = {
    enable = lib.mkEnableOption "NVIDIA Container Toolkit for Docker/Podman";
  };

  config = lib.mkIf cfg.enable {
    hardware.nvidia-container-toolkit = {
      enable = true;
    };
  };
}
