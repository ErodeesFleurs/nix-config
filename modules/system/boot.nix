{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.system.boot;
in
{
  options.modules.system.boot = {
    enable = lib.mkEnableOption "Boot configuration";

    useLatestKernel = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use the latest Linux kernel";
    };

    kernelPackages = lib.mkOption {
      type = lib.types.nullOr lib.types.raw;
      default = null;
      description = "Kernel packages to use. If null, uses latest or default.";
      example = lib.literalExpression "pkgs.linuxPackages_zen";
    };

    enableSystemdBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable systemd-boot bootloader";
    };

    enableSystemdInitrd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable systemd in initrd";
    };

    efiCanTouchVariables = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow modifying EFI variables";
    };

    enableIOMMU = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable IOMMU support (for AMD)";
    };

    extraKernelParams = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional kernel parameters";
      example = [
        "quiet"
        "splash"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      # Initrd configuration
      initrd = {
        systemd.enable = cfg.enableSystemdInitrd;
      };

      # Bootloader configuration
      loader = lib.mkIf cfg.enableSystemdBoot {
        systemd-boot = {
          enable = true;
        };
        efi = {
          canTouchEfiVariables = cfg.efiCanTouchVariables;
        };
      };

      # Kernel configuration - use mkDefault to allow overrides
      kernelPackages = lib.mkDefault (
        if cfg.kernelPackages != null then
          cfg.kernelPackages
        else if cfg.useLatestKernel then
          pkgs.linuxPackages_latest
        else
          pkgs.linuxPackages
      );

      # Kernel parameters
      kernelParams =
        lib.optionals cfg.enableIOMMU [
          "amd_iommu=on"
          "iommu=pt"
        ]
        ++ cfg.extraKernelParams;
    };
  };
}
