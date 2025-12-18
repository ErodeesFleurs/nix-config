{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.programs.gaming;
in
{
  options.modules.programs.gaming = {
    enable = lib.mkEnableOption "Gaming support and optimizations";

    enablePerformanceOptimizations = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable performance optimizations for gaming";
    };

    enableGamemode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Feral GameMode for performance optimization";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional gaming-related packages";
      example = lib.literalExpression ''
        with pkgs; [
          lutris
          heroic
          legendary-gl
        ]
      '';
    };

    wine = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Wine for running Windows games";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.wineWowPackages.stable;
        description = "Wine package to use";
      };
    };

    openPorts = {
      tcp = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ ];
        description = "Additional TCP ports to open for gaming";
        example = [
          27015
          7777
        ];
      };

      udp = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ ];
        description = "Additional UDP ports to open for gaming";
        example = [
          27015
          7777
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable GameMode for performance
    programs.gamemode = lib.mkIf cfg.enableGamemode {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
      };
    };

    # Install gaming utilities
    environment.systemPackages =
      with pkgs;
      [
        # Monitoring tools
        mangohud
        goverlay
      ]
      ++ lib.optionals cfg.wine.enable [
        cfg.wine.package
        winetricks
      ]
      ++ cfg.extraPackages;

    # Wine support
    hardware.graphics = lib.mkIf cfg.wine.enable {
      enable32Bit = true;
    };

    # Performance optimizations
    boot.kernel.sysctl = lib.mkIf cfg.enablePerformanceOptimizations {
      # Reduce swappiness for better gaming performance
      "vm.swappiness" = lib.mkDefault 10;

      # Increase file handle limits
      "fs.file-max" = lib.mkDefault 2097152;

      # Network optimizations
      "net.core.rmem_max" = lib.mkDefault 16777216;
      "net.core.wmem_max" = lib.mkDefault 16777216;
      "net.ipv4.tcp_rmem" = lib.mkDefault "4096 87380 16777216";
      "net.ipv4.tcp_wmem" = lib.mkDefault "4096 65536 16777216";
    };

    # Open firewall ports for gaming
    networking.firewall = lib.mkIf (cfg.openPorts.tcp != [ ] || cfg.openPorts.udp != [ ]) {
      allowedTCPPorts = cfg.openPorts.tcp;
      allowedUDPPorts = cfg.openPorts.udp;
    };

    # Gaming session environment variables
    environment.sessionVariables = {
      # Enable MangoHud by default (can be toggled with Shift_R+F12)
      MANGOHUD = lib.mkDefault "0";

      # AMD GPU optimizations
      AMD_VULKAN_ICD = lib.mkDefault "RADV";

      # Enable Steam integration
      STEAM_RUNTIME = lib.mkDefault "1";
    };

    # Security limits for gaming
    security.pam.loginLimits = lib.mkIf cfg.enablePerformanceOptimizations [
      {
        domain = "*";
        type = "hard";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "*";
        type = "soft";
        item = "memlock";
        value = "unlimited";
      }
    ];
  };
}
