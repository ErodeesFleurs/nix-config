{ config, lib, ... }:

let
  cfg = config.modules.programs.systemd;
in
{
  options.modules.programs.systemd = {
    enable = lib.mkEnableOption "systemd 小工具";

    uwsm = {
      enable = lib.mkEnableOption "启用 UWSM 管理器";
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
