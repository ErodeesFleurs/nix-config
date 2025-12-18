/*
  nix-config/modules/system/boot.nix
  引导与内核配置模块 — Boot & kernel configuration module

  CN: 本模块负责系统引导和内核相关的可配置选项（例如启用 systemd-boot、选择内核包、
      initrd systemd 支持、EFI 变量访问和 IOMMU 参数）。文档为中英双语，便于维护与阅读。
  EN: This module provides configurable options around boot and kernel settings
      (e.g. toggling systemd-boot, selecting kernel packages, enabling systemd in
      initrd, EFI variable access and IOMMU kernel params). Documentation is
      bilingual (CN/EN) for clarity.
*/

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.boot;
in
{
  options.modules.boot = {
    enable = lib.mkEnableOption "Boot configuration / 引导配置";

    useLatestKernel = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Use the latest available Linux kernel package set.
        CN: 使用最新可用的 Linux 内核包集合。
        Note: If `kernelPackages` is explicitly set (non-null), that value is used instead.
        注意：如果显式设置了 `kernelPackages`（非 null），则优先使用该值。
      '';
    };

    kernelPackages = lib.mkOption {
      type = lib.types.nullOr lib.types.raw;
      default = null;
      description = ''
        Specify an exact kernel package set (e.g. pkgs.linuxPackages_zen).
        CN: 指定精确的内核包集合（例如：pkgs.linuxPackages_zen）。
        If left null, the module chooses between latest or the distro default based on `useLatestKernel`.
        如果为 null，则根据 `useLatestKernel` 在最新和发行版默认之间选择。
      '';
      example = lib.literalExpression "pkgs.linuxPackages_zen";
    };

    enableSystemdBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable systemd-boot as the bootloader.
        CN: 启用 systemd-boot 引导加载器。
        Set to false if you prefer another bootloader (e.g. GRUB).
        如果使用其它引导程序（如 GRUB），请设为 false。
      '';
    };

    enableSystemdInitrd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Include systemd in the initrd (early-boot systemd support).
        CN: 在 initrd 中包含 systemd（早期引导的 systemd 支持）。
        Useful for setups that need systemd services available before the rootfs is mounted.
        在根文件系统挂载前需要使用 systemd 服务的场景很有用。
      '';
    };

    efiCanTouchVariables = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Allow writing/modifying EFI variables (required by systemd-boot and some installers).
        CN: 允许写入/修改 EFI 变量（systemd-boot 和部分安装器需要）。
        Warning: enabling this grants the running system power to modify firmware settings.
        警告：启用此项会授予系统修改固件设置的权限。
      '';
    };

    enableIOMMU = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable IOMMU related kernel boot parameters (commonly needed for AMD/virtualization).
        CN: 启用与 IOMMU 相关的内核启动参数（常用于 AMD / 虚拟化）。
        When enabled the module appends recommended kernel params (amd_iommu=on, iommu=pt).
        启用时模块会追加推荐的内核参数（amd_iommu=on、iommu=pt）。
      '';
    };

    extraKernelParams = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Additional kernel command-line parameters to append.
        CN: 追加的额外内核命令行参数。
        Example: [ "quiet" "splash" ].
        示例: [ "quiet" "splash" ]。
      '';
      example = [
        "quiet"
        "splash"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      # Initrd configuration
      # CN: initrd 配置
      initrd = {
        systemd.enable = cfg.enableSystemdInitrd;
      };

      # Bootloader configuration
      # CN: 引导加载器配置
      loader = lib.mkIf cfg.enableSystemdBoot {
        systemd-boot = {
          enable = true;
        };
        efi = {
          canTouchEfiVariables = cfg.efiCanTouchVariables;
        };
      };

      # Kernel packages selection -- use mkDefault to make the choice overridable
      # CN: 内核包选择 — 使用 mkDefault 以允许上层覆盖
      kernelPackages = lib.mkDefault (
        if cfg.kernelPackages != null then
          cfg.kernelPackages
        else if cfg.useLatestKernel then
          pkgs.linuxPackages_latest
        else
          pkgs.linuxPackages
      );

      # Kernel parameters
      # CN: 内核参数
      kernelParams =
        lib.optionals cfg.enableIOMMU [
          "amd_iommu=on"
          "iommu=pt"
        ]
        ++ cfg.extraKernelParams;
    };
  };
}
