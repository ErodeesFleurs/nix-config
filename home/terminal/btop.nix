{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.terminal.btop;
in
{
  options.homeModules.terminal.btop = {
    enable = lib.mkEnableOption "Btop system monitor";

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Btop configuration settings";
      example = {
        color_theme = "Default";
        theme_background = false;
        update_ms = 2000;
        proc_sorting = "cpu lazy";
        proc_tree = false;
        proc_colors = true;
        proc_gradient = true;
        proc_per_core = false;
        proc_mem_bytes = true;
        cpu_graph_upper = "total";
        cpu_graph_lower = "total";
        cpu_invert_lower = true;
        cpu_single_graph = false;
        show_uptime = true;
        check_temp = true;
        cpu_sensor = "Auto";
        show_coretemp = true;
        temp_scale = "celsius";
        show_battery = true;
        show_cpu_freq = true;
        mem_graphs = true;
        mem_below_net = false;
        show_swap = true;
        swap_disk = true;
        show_disks = true;
        only_physical = true;
        use_fstab = true;
        show_io_stat = true;
        io_mode = false;
        io_graph_combined = false;
        net_download = 100;
        net_upload = 100;
        net_auto = true;
        net_sync = false;
        net_color_fixed = false;
        show_init = false;
        disable_unicode = false;
      };
    };

    theme = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Btop color theme";
      example = "gruvbox_dark_v2";
    };

    updateInterval = lib.mkOption {
      type = lib.types.int;
      default = 2000;
      description = "Update interval in milliseconds";
    };

    cpuSettings = {
      graphUpper = lib.mkOption {
        type = lib.types.str;
        default = "total";
        description = "CPU graph upper type";
      };

      graphLower = lib.mkOption {
        type = lib.types.str;
        default = "total";
        description = "CPU graph lower type";
      };

      singleGraph = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Show single CPU graph";
      };

      invertLower = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Invert lower CPU graph";
      };

      perCore = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Show per-core CPU usage";
      };

      showFreq = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show CPU frequency";
      };
    };

    memorySettings = {
      graphs = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show memory graphs";
      };

      belowNet = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Place memory below network";
      };

      showSwap = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show swap usage";
      };

      swapDisk = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show swap as disk";
      };
    };

    processSettings = {
      sorting = lib.mkOption {
        type = lib.types.str;
        default = "cpu lazy";
        description = "Process sorting method";
      };

      tree = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Show process tree";
      };

      colors = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable process colors";
      };

      gradient = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable process gradient";
      };

      memBytes = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show memory in bytes";
      };
    };

    diskSettings = {
      show = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show disk usage";
      };

      onlyPhysical = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show only physical disks";
      };

      useFstab = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use fstab for disk discovery";
      };

      showIoStat = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show disk I/O statistics";
      };

      ioMode = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable I/O mode";
      };
    };

    networkSettings = {
      download = lib.mkOption {
        type = lib.types.int;
        default = 100;
        description = "Network download graph height";
      };

      upload = lib.mkOption {
        type = lib.types.int;
        default = 100;
        description = "Network upload graph height";
      };

      auto = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Auto-scale network graphs";
      };

      sync = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Sync network graph scales";
      };

      colorFixed = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Use fixed colors for network";
      };
    };

    temperatureSettings = {
      checkTemp = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable temperature monitoring";
      };

      sensor = lib.mkOption {
        type = lib.types.str;
        default = "Auto";
        description = "Temperature sensor to use";
      };

      showCoretemp = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show core temperatures";
      };

      scale = lib.mkOption {
        type = lib.types.enum [
          "celsius"
          "fahrenheit"
          "kelvin"
        ];
        default = "celsius";
        description = "Temperature scale";
      };
    };

    miscSettings = {
      showUptime = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show system uptime";
      };

      showBattery = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show battery status";
      };

      showInit = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Show init system";
      };

      disableUnicode = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Disable Unicode characters";
      };

      themeBackground = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Use theme background";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;

      settings = lib.mkMerge [
        {
          # Theme
          color_theme = lib.mkIf (cfg.theme != null) cfg.theme;
          theme_background = cfg.miscSettings.themeBackground;

          # Update interval
          update_ms = cfg.updateInterval;

          # CPU settings
          cpu_graph_upper = cfg.cpuSettings.graphUpper;
          cpu_graph_lower = cfg.cpuSettings.graphLower;
          cpu_single_graph = cfg.cpuSettings.singleGraph;
          cpu_invert_lower = cfg.cpuSettings.invertLower;
          proc_per_core = cfg.cpuSettings.perCore;
          show_cpu_freq = cfg.cpuSettings.showFreq;

          # Memory settings
          mem_graphs = cfg.memorySettings.graphs;
          mem_below_net = cfg.memorySettings.belowNet;
          show_swap = cfg.memorySettings.showSwap;
          swap_disk = cfg.memorySettings.swapDisk;

          # Process settings
          proc_sorting = cfg.processSettings.sorting;
          proc_tree = cfg.processSettings.tree;
          proc_colors = cfg.processSettings.colors;
          proc_gradient = cfg.processSettings.gradient;
          proc_mem_bytes = cfg.processSettings.memBytes;

          # Disk settings
          show_disks = cfg.diskSettings.show;
          only_physical = cfg.diskSettings.onlyPhysical;
          use_fstab = cfg.diskSettings.useFstab;
          show_io_stat = cfg.diskSettings.showIoStat;
          io_mode = cfg.diskSettings.ioMode;

          # Network settings
          net_download = cfg.networkSettings.download;
          net_upload = cfg.networkSettings.upload;
          net_auto = cfg.networkSettings.auto;
          net_sync = cfg.networkSettings.sync;
          net_color_fixed = cfg.networkSettings.colorFixed;

          # Temperature settings
          check_temp = cfg.temperatureSettings.checkTemp;
          cpu_sensor = cfg.temperatureSettings.sensor;
          show_coretemp = cfg.temperatureSettings.showCoretemp;
          temp_scale = cfg.temperatureSettings.scale;

          # Misc settings
          show_uptime = cfg.miscSettings.showUptime;
          show_battery = cfg.miscSettings.showBattery;
          show_init = cfg.miscSettings.showInit;
          disable_unicode = cfg.miscSettings.disableUnicode;
        }
        cfg.settings
      ];
    };
  };
}
