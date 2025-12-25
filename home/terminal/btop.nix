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

    update-interval = lib.mkOption {
      type = lib.types.int;
      default = 2000;
      description = "Update interval in milliseconds";
    };

    cpu-settings = {
      graph-upper = lib.mkOption {
        type = lib.types.str;
        default = "total";
        description = "CPU graph upper type";
      };

      graph-lower = lib.mkOption {
        type = lib.types.str;
        default = "total";
        description = "CPU graph lower type";
      };

      single-graph = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Show single CPU graph";
      };

      invert-lower = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Invert lower CPU graph";
      };

      per-core = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Show per-core CPU usage";
      };

      show-freq = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show CPU frequency";
      };
    };

    memory-settings = {
      graphs = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show memory graphs";
      };

      below-net = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Place memory below network";
      };

      show-swap = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show swap usage";
      };

      swap-disk = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show swap as disk";
      };
    };

    process-settings = {
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

      mem-bytes = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show memory in bytes";
      };
    };

    disk-settings = {
      show = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show disk usage";
      };

      only-physical = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show only physical disks";
      };

      use-fstab = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use fstab for disk discovery";
      };

      show-io-stat = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show disk I/O statistics";
      };

      io-mode = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable I/O mode";
      };
    };

    network-settings = {
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

      color-fixed = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Use fixed colors for network";
      };
    };

    temperature-settings = {
      check-temp = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable temperature monitoring";
      };

      sensor = lib.mkOption {
        type = lib.types.str;
        default = "Auto";
        description = "Temperature sensor to use";
      };

      show-coretemp = lib.mkOption {
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

    misc-settings = {
      show-uptime = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show system uptime";
      };

      show-battery = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show battery status";
      };

      show-init = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Show init system";
      };

      disable-unicode = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Disable Unicode characters";
      };

      theme-background = lib.mkOption {
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
          theme_background = cfg.misc-settings.theme-background;

          # Update interval
          update_ms = cfg.update-interval;

          # CPU settings
          cpu_graph_upper = cfg.cpu-settings.graph-upper;
          cpu_graph_lower = cfg.cpu-settings.graph-lower;
          cpu_single_graph = cfg.cpu-settings.single-graph;
          cpu_invert_lower = cfg.cpu-settings.invert-lower;
          proc_per_core = cfg.cpu-settings.per-core;
          show_cpu_freq = cfg.cpu-settings.show-freq;

          # Memory settings
          mem_graphs = cfg.memory-settings.graphs;
          mem_below_net = cfg.memory-settings.below-net;
          show_swap = cfg.memory-settings.show-swap;
          swap_disk = cfg.memory-settings.swap-disk;

          # Process settings
          proc_sorting = cfg.process-settings.sorting;
          proc_tree = cfg.process-settings.tree;
          proc_colors = cfg.process-settings.colors;
          proc_gradient = cfg.process-settings.gradient;
          proc_mem_bytes = cfg.process-settings.mem-bytes;

          # Disk settings
          show_disks = cfg.disk-settings.show;
          only_physical = cfg.disk-settings.only-physical;
          use_fstab = cfg.disk-settings.use-fstab;
          show_io_stat = cfg.disk-settings.show-io-stat;
          io_mode = cfg.disk-settings.io-mode;

          # Network settings
          net_download = cfg.network-settings.download;
          net_upload = cfg.network-settings.upload;
          net_auto = cfg.network-settings.auto;
          net_sync = cfg.network-settings.sync;
          net_color_fixed = cfg.network-settings.color-fixed;

          # Temperature settings
          check_temp = cfg.temperature-settings.check-temp;
          cpu_sensor = cfg.temperature-settings.sensor;
          show_coretemp = cfg.temperature-settings.show-coretemp;
          temp_scale = cfg.temperature-settings.scale;

          # Misc settings
          show_uptime = cfg.misc-settings.show-uptime;
          show_battery = cfg.misc-settings.show-battery;
          show_init = cfg.misc-settings.show-init;
          disable_unicode = cfg.misc-settings.disable-unicode;
        }
        cfg.settings
      ];
    };
  };
}
