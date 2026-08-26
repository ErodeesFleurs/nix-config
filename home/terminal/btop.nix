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
  };

  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;

      settings = {
        color_theme = "monet";
        theme_background = true;
        update_ms = 2000;

        cpu_graph_upper = "total";
        cpu_graph_lower = "total";
        cpu_single_graph = false;
        cpu_invert_lower = true;
        proc_per_core = false;
        show_cpu_freq = true;

        mem_graphs = true;
        mem_below_net = false;
        show_swap = true;
        swap_disk = true;

        proc_sorting = "cpu lazy";
        proc_tree = false;
        proc_colors = true;
        proc_gradient = true;
        proc_mem_bytes = true;

        show_disks = true;
        only_physical = true;
        use_fstab = true;
        show_io_stat = true;
        io_mode = false;

        net_download = 100;
        net_upload = 100;
        net_auto = true;
        net_sync = false;
        net_color_fixed = false;

        check_temp = true;
        cpu_sensor = "Auto";
        show_coretemp = true;
        temp_scale = "celsius";

        show_uptime = true;
        show_battery = true;
        show_init = false;
        disable_unicode = false;
      };
    };
  };
}
