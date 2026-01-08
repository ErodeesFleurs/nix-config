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

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nemo-with-extensions;
      description = "Nemo file manager package";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (cfg.package.override {
        extensions = with pkgs; [
          nemo-python
          nemo-fileroller
        ];
      })
    ];
  };
}
