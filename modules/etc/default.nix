{
  config,
  lib,
  ...
}:

/*
  nix-config/modules/etc/default.nix
  /etc overlay, machine-id and environment defaults implementation

  This submodule implements the `/etc` overlay behaviour and writes a minimal set of files
  into `environment.etc` when the overlay is immutable (for example: `machine-id`). It also
  declares persistent bind mounts and tmpfiles rules used to ensure expected persistent
  directories exist on systems that provide a `/persist` partition.

  CN:
  本子模块实现 `/etc` overlay（enable + mutable）行為。在 overlay 为不可变时会向
  `environment.etc` 写入最小集合的必要文件（例如 `machine-id`）。同时声明用于保证
  持久化目录存在的绑定挂载与 tmpfiles 规则。
*/

let
  # Prefer explicit `modules.etc` for new-style configuration.
  # Legacy fallback has been removed; callers must migrate to `modules.etc`.
  cfg = config.modules.etc or { };
in
{
  # Declare the `/etc` / system-state related options in the new `modules.etc` namespace.
  # These keys were migrated into `modules.etc` and cover overlay and minimal system state
  # concerns (machine-id / stateVersion / nixos-init).
  options.modules.etc = {
    enable = lib.mkEnableOption "System /etc and state options / /etc 与系统状态选项";

    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "26.05";
      description = ''
        NixOS state version used for compatibility logic.
        CN: NixOS 的 stateVersion（影响一些模块的向后兼容逻辑），请根据系统实际版本调整。
        EN: The NixOS stateVersion value (affects module compatibility behavior).
      '';
    };

    enableInit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable the `nixos-init` helper for system initialization tasks.
        CN: 是否启用 nixos-init（用于初始系统引导/安装流程的工具）。
        EN: Enable the `nixos-init` helper for initial system setup tasks.
      '';
    };

    overlayMutable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Make the /etc overlay mutable. When false, a minimal set of files will be written
        into `environment.etc` so that services and bind-mounts have expected file paths.
        CN: 是否允许 /etc overlay 可写（使得 /etc 上的覆盖可变更）。若为 false，将写入一组最小文件到 `environment.etc`。
        EN: Make the /etc overlay writable; when false some paths will be populated from the NixOS configuration instead.
      '';
    };

    machineId = lib.mkOption {
      type = lib.types.str;
      default = builtins.hashString "md5" (config.networking.hostName or "unknown") + "\n";
      description = ''
        Deterministic machine ID written to /etc/machine-id when the overlay is immutable.
        CN: 在 /etc overlay 不可变时写入的固定 machine-id 值。
        EN: Deterministic machine-id used when `/etc` overlay is kept immutable.
      '';
    };
  };

  # Implementation: apply behaviour using whichever namespace is configured (prefer modules.etc).
  config = lib.mkIf cfg.enable {
    # Ensure basic system-level `system.*` values related to /etc overlay and state are applied here.
    system = {
      # Keep stateVersion and nixos-init colocated with system-level concerns.
      stateVersion = cfg.stateVersion;
      nixos-init.enable = cfg.enableInit;

      # /etc overlay configuration: always enabled, mutability controlled by option
      etc = {
        overlay = {
          enable = true;
          mutable = cfg.overlayMutable;
        };
      };
    };

    # When the /etc overlay is immutable, we must populate a minimal set of files under /etc
    # so that later mount-binds and services have their expected files/dirs.
    environment = lib.mkIf (!cfg.overlayMutable) {
      etc = {
        # Write a deterministic machine-id when overlay is immutable.
        # CN: 当 /etc overlay 为只读/不可变时，写入固定 machine-id。
        "machine-id".text = cfg.machineId;

        # Keep files to ensure the directories exist in the Nix store when overlay is immutable.
        # They are typically empty placeholder files used to make the paths appear in the Nix-managed /etc.
        "NetworkManager/system-connections/.keep".text = "";
        "v2raya/.keep".text = "";
      };
    };

    # Persistent bind mounts typically used to mount data from a `/persist` partition into /etc
    # so that runtime modifications are stored off the read-only Nix-managed file tree.
    #
    # These fileSystems entries are intentionally unconditional when cfg.enable is true so that the
    # system will attempt to bind the expected `/persist` locations.
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

    # Ensure the expected persistent directories exist on boot with correct permissions using tmpfiles.
    systemd.tmpfiles.rules = [
      # Create directories on /persist if they don't exist. Mode and ownership chosen conservatively.
      "d /persist/etc/NetworkManager/system-connections 0700 root root -"
      "d /persist/var/lib/nixos 0755 root root -"
      "d /persist/etc/v2raya 0750 root root -"
    ];
  };
}
