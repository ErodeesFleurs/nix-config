{
  config,
  lib,
  ...
}:

let
  # Accept either the legacy dashed name or the new camelCase name from host configs.
  # Normalize into an attribute set with an `enable` boolean to avoid null/undefined and accept
  # either an attribute set or a bare boolean value.
  cfg = config.modules.hardware.nvidia-container;
in
{
  # Declare both the canonical camelCase option and the legacy dashed option so they are visible
  # in `nixos-option` listings. Both accept a boolean or an attribute set with `enable`.
  options.modules.hardware.nvidia-container = {
    enable = lib.mkEnableOption "NVIDIA Container Toolkit for Docker/Podman";
  };

  # We normalize at runtime from either `modules.hardware.nvidiaContainer` or
  # `modules.hardware.\"nvidia-container\"` into `cfg` above. Prefer the camelCase name going forward.

  config = lib.mkIf cfg.enable {
    hardware.nvidia-container-toolkit = {
      enable = true;
    };
  };
}
