{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeModules.nemo;
in
{
  options.homeModules.nemo = {
    enable = lib.mkEnableOption "Nemo file manager";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (nemo-with-extensions.override {
        extensions = with pkgs; [
          nemo-python
          nemo-fileroller
        ];
      })
    ];
  };
}
