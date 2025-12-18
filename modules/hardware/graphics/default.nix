{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.hardware.graphics;
in
{
  options.modules.hardware.graphics = {
    enable = lib.mkEnableOption "Graphics hardware support";

    enable32Bit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable 32-bit graphics driver support";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional graphics packages to install";
      example = lib.literalExpression "[ pkgs.libva pkgs.vaapiVdpau ]";
    };

    extraPackages32 = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional 32-bit graphics packages to install";
    };

    vulkan = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Vulkan support";
      };

      validation = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Vulkan validation layers (for development)";
      };
    };

    vaapi = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable VA-API video acceleration";
      };
    };

    vdpau = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable VDPAU video acceleration";
      };
    };

    opencl = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable OpenCL support";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = cfg.enable32Bit;
      extraPackages =
        cfg.extraPackages
        ++ lib.optionals cfg.vulkan.enable [
          pkgs.vulkan-loader
          pkgs.vulkan-tools
        ]
        ++ lib.optionals cfg.vulkan.validation [ pkgs.vulkan-validation-layers ]
        ++ lib.optionals cfg.vaapi.enable [
          pkgs.libva
          pkgs.libva-utils
        ]
        ++ lib.optionals cfg.vdpau.enable [
          pkgs.vdpauinfo
          pkgs.libvdpau-va-gl
        ]
        ++ lib.optionals cfg.opencl.enable [
          pkgs.ocl-icd
          pkgs.clinfo
        ];

      extraPackages32 =
        cfg.extraPackages32
        ++ lib.optionals cfg.enable32Bit [
          pkgs.pkgsi686Linux.vulkan-loader
        ];
    };

    # Environment variables for graphics
    environment.sessionVariables = lib.mkMerge [
      (lib.mkIf cfg.vaapi.enable {
        LIBVA_DRIVER_NAME = lib.mkDefault "auto";
      })
      (lib.mkIf cfg.vdpau.enable {
        VDPAU_DRIVER = lib.mkDefault "auto";
      })
    ];

    # Install utilities
    environment.systemPackages =
      with pkgs;
      [
        mesa-demos
      ]
      ++ lib.optionals cfg.vulkan.enable [ vulkan-tools ];
  };
}
