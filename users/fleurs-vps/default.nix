# Server-only Home Manager profile; no desktop/common.nix import.
{ ... }:
{
  imports = [ ../../home/terminal/shell/starship.nix ];
  home = {
    username = "fleurs";
    homeDirectory = "/home/fleurs";
    stateVersion = "26.05";
  };
  programs = {
    nushell = {
      enable = true;
      loadSessionVariables = true;
      settings.show_banner = false;
    };
    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
    btop.enable = true;
    helix = {
      enable = true;
      defaultEditor = true;
    };
    home-manager.enable = true;
  };
}
