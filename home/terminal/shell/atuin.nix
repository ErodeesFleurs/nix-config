{ config, lib, ... }:

{
  programs.atuin = lib.mkIf config.homeModules.terminal.shell.nushell.enable {
    enable = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableNushellIntegration = true;
    enableZshIntegration = false;
    flags = [ "--disable-up-arrow" ];
    daemon.enable = false;
    settings = {
      auto_sync = false;
      update_check = false;
    };
  };
}
