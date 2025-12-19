{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.hardware.nvidia;
in
{
  imports = [ ./container ];

  options.modules.hardware.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU support";

    modesetting = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable kernel modesetting";
    };

    power-management = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable power management";
      };

      finegrained = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable fine-grained power management";
      };
    };

    open = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use open-source NVIDIA kernel modules";
    };

    nvidia-settings = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable nvidia-settings tool";
    };

    package = lib.mkOption {
      type = lib.types.enum [
        "stable"
        "beta"
        "production"
        "legacy_470"
        "legacy_390"
      ];
      default = "stable";
      description = "NVIDIA driver package version to use";
    };

    prime = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable NVIDIA PRIME (for hybrid graphics)";
      };

      offload = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable PRIME offload mode";
        };

        enable-offload-cmd = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable nvidia-offload command";
        };
      };

      sync = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable PRIME sync mode (render on NVIDIA, display on iGPU)";
        };
      };

      reverse-sync = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable PRIME reverse sync (render on iGPU, display on NVIDIA)";
        };
      };

      amdgpu-bus-id = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Bus ID of AMD GPU (e.g., 'PCI:0:6:0')";
        example = "PCI:0:6:0";
      };

      intel-bus-id = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Bus ID of Intel GPU (e.g., 'PCI:0:2:0')";
        example = "PCI:0:2:0";
      };

      nvidia-bus-id = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Bus ID of NVIDIA GPU (e.g., 'PCI:0:1:0')";
        example = "PCI:0:1:0";
      };
    };

    apply-patches = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Apply additional patches to the driver";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable graphics/OpenGL
    hardware.graphics.enable = true;

    # NVIDIA driver configuration
    hardware.nvidia = {
      modesetting.enable = cfg.modesetting;

      powerManagement = {
        enable = cfg.power-management.enable;
        finegrained = cfg.power-management.finegrained;
      };

      open = cfg.open;
      nvidiaSettings = cfg.nvidia-settings;

      # Select package version
      package =
        let
          kernelPackages = config.boot.kernelPackages.nvidiaPackages;
          selectedPackage =
            {
              stable = kernelPackages.stable;
              beta = kernelPackages.beta;
              production = kernelPackages.production;
              legacy_470 = kernelPackages.legacy_470;
              legacy_390 = kernelPackages.legacy_390;
            }
            .${cfg.package};
        in
        if cfg.apply-patches && cfg.open then
          selectedPackage
          // {
            open = selectedPackage.open.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [
                # (pkgs.fetchpatch {
                #   name = "get_dev_pagemap.patch";
                #   url = "https://github.com/NVIDIA/open-gpu-kernel-modules/commit/3e230516034d29e84ca023fe95e284af5cd5a065.patch";
                #   hash = "sha256-BhL4mtuY5W+eLofwhHVnZnVf0msDj7XBxskZi8e6/k8=";
                # })
                # 说不定啥时候又有bug。
              ];
            });
          }
        else
          selectedPackage;

      # PRIME configuration
      prime = lib.mkIf cfg.prime.enable {
        offload = lib.mkIf cfg.prime.offload.enable {
          enable = true;
          enableOffloadCmd = cfg.prime.offload.enable-offload-cmd;
        };

        sync.enable = cfg.prime.sync.enable;
        reverseSync.enable = cfg.prime.reverse-sync.enable;

        amdgpuBusId = lib.mkIf (cfg.prime.amdgpu-bus-id != null) cfg.prime.amdgpu-bus-id;
        intelBusId = lib.mkIf (cfg.prime.intel-bus-id != null) cfg.prime.intel-bus-id;
        nvidiaBusId = lib.mkIf (cfg.prime.nvidia-bus-id != null) cfg.prime.nvidia-bus-id;
      };
    };

    # Add nvidia-offload script if prime offload is enabled
    environment.systemPackages =
      lib.optionals (cfg.prime.enable && cfg.prime.offload.enable && cfg.prime.offload.enable-offload-cmd)
        [
          (pkgs.writeShellScriptBin "nvidia-offload" ''
            export __NV_PRIME_RENDER_OFFLOAD=1
            export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
            export __GLX_VENDOR_LIBRARY_NAME=nvidia
            export __VK_LAYER_NV_optimus=NVIDIA_only
            exec "$@"
          '')
        ];
  };
}
