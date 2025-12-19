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

    use-latest-kernel = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        使用最新可用的 Linux 内核包集合。
        如果显式设置了 `kernelPackages`（非 null），则优先使用该值。
      '';
    };

    kernel-packages = lib.mkOption {
      type = lib.types.nullOr lib.types.raw;
      default = null;
      description = ''
        指定精确的内核包集合（例如：pkgs.linuxPackages_zen）。
        如果为 null，则根据 `use-latest-kernel` 在最新和发行版默认之间选择。
      '';
      example = lib.literalExpression "pkgs.linuxPackages_zen";
    };

    enable-systemd-boot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        启用 systemd-boot 引导加载器。
        如果使用其它引导程序（如 GRUB），请设为 false。
      '';
    };

    enable-systemd-initrd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        在 initrd 中包含 systemd（早期引导的 systemd 支持）。
        在根文件系统挂载前需要使用 systemd 服务的场景很有用。
      '';
    };

    efi-can-touch-variables = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        允许写入/修改 EFI 变量（systemd-boot 和部分安装器需要）。
        启用此项会授予系统修改固件设置的权限。
      '';
    };

    enable-iommu = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        启用与 IOMMU 相关的内核启动参数（常用于 AMD / 虚拟化）。
        启用时模块会追加推荐的内核参数（amd_iommu=on、iommu=pt）。
      '';
    };

    extra-kernel-params = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        追加的额外内核命令行参数。
        Example: [ "quiet" "splash" ]
      '';
      example = [
        "quiet"
        "splash"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      # initrd 配置
      initrd = {
        systemd.enable = cfg.enable-systemd-initrd;
      };

      # 引导加载器配置
      loader = lib.mkIf cfg.enable-systemd-boot {
        systemd-boot = {
          enable = true;
        };
        efi = {
          canTouchEfiVariables = cfg.efi-can-touch-variables;
        };
      };

      # 内核包选择 — 使用 mkDefault 以允许上层覆盖
      kernelPackages = lib.mkDefault (
        if cfg.kernel-packages != null then
          cfg.kernel-packages
        else if cfg.use-latest-kernel then
          pkgs.linuxPackages_latest
        else
          pkgs.linuxPackages
      );

      # 内核参数
      kernelParams =
        lib.optionals cfg.enable-iommu [
          "amd_iommu=on"
          "iommu=pt"
        ]
        ++ cfg.extra-kernel-params;
    };
  };
}
