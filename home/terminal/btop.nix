{
  config,
  lib,
  pkgs,
  osConfig ? { },
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
      # NVML 由系统 NVIDIA 驱动提供；cudaSupport 为 btop 加入驱动库搜索路径，
      # 不引入完整 CUDA 工具链。按目标配置判断，不探测执行求值的机器。
      package = pkgs.btop.override {
        cudaSupport = builtins.elem "nvidia" (osConfig.services.xserver.videoDrivers or [ ]);
      };

      settings = {
        color_theme = "monet";
        theme_background = true;
        update_ms = 2000;

        cpu_graph_upper = "total";
        # 有 GPU 时下半图显示 GPU 使用率，否则自动回退到 CPU。
        cpu_graph_lower = "Auto";
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
