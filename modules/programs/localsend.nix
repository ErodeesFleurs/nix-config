{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.programs.localsend;
in
{
  options.modules.programs.localsend = {
    enable = lib.mkEnableOption "LocalSend service / 本地传输服务";
  };

  config = lib.mkIf cfg.enable {
    programs.localsend = {
      enable = true;
      openFirewall = true;
    };
  };
}
