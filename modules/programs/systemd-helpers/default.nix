{ config, lib, ... }:

let
  cfg = config.modules.programs.systemd;
in
{
  options.modules.programs.systemd = {
    enable = lib.mkEnableOption "Small systemd/program helpers / systemd 小工具";

    uwsm = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          启用 uwsm 程序/服务（如果系统包中存在该程序）。
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs = lib.mkIf cfg.uwsm.enable {
      uwsm = {
        enable = true;
      };
    };
  };
}
