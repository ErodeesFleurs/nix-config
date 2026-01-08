{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.etc or { };
in
{
  options.modules.etc = {
    enable = lib.mkEnableOption "etc 与系统状态选项";

    state-version = lib.mkOption {
      type = lib.types.str;
      default = "26.05";
      description = ''
        NixOS 的 stateVersion（影响一些模块的向后兼容逻辑），请根据系统实际版本调整。
      '';
    };

    enable-init = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        是否启用 nixos-init（用于初始系统引导/安装流程的工具）。
      '';
    };

    overlay-mutable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        是否允许 /etc overlay 可写（使得 /etc 上的覆盖可变更）。若为 false，将写入一组最小文件到 `environment.etc`。
      '';
    };

    machine-id = lib.mkOption {
      type = lib.types.str;
      default = builtins.hashString "md5" (config.networking.hostName or "unknown") + "\n";
      description = ''
        在 /etc overlay 不可变时写入的固定 machine-id 值。
      '';
    };
  };

  # 实现：根据所配置的命名空间应用行为（优先使用 modules.etc）。
  config = lib.mkIf cfg.enable {
    # 确保与 /etc overlay 与系统状态相关的基础 system.* 系统级设置在此处被应用。
    system = {
      # 将 stateVersion 与 nixos-init 与其它系统级相关项放在一起管理。
      stateVersion = cfg.state-version;
      nixos-init.enable = cfg.enable-init;

      # /etc overlay 配置：始终启用，是否可写由选项控制
      etc = {
        overlay = {
          enable = true;
          mutable = cfg.overlay-mutable;
        };
      };
    };

    # 当 /etc overlay 为不可变时，需要在 /etc 下填充一组最小文件，
    # 以便后续的挂载绑定与服务能够找到它们期望的文件和目录。
    environment = lib.mkIf (!cfg.overlay-mutable) {
      etc = {
        "machine-id".text = cfg.machine-id;
        "NetworkManager/system-connections/.keep".text = "";
        "v2raya/.keep".text = "";
      };
    };

    fileSystems = {
      "/etc/NetworkManager/system-connections" = {
        device = "/persist/etc/NetworkManager/system-connections";
        options = [
          "bind"
          "rw"
        ];
        noCheck = true;
      };

      "/etc/v2raya" = {
        device = "/persist/etc/v2raya";
        options = [
          "bind"
          "rw"
        ];
        noCheck = true;
      };
    };

    systemd.tmpfiles.rules = [
      "d /persist/etc/NetworkManager/system-connections 0700 root root -"
      "d /persist/var/lib/nixos 0755 root root -"
      "d /persist/etc/v2raya 0750 root root -"
    ];
  };
}
