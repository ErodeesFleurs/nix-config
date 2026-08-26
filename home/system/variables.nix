{ ... }:

{
  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "ghostty";
    TERM = "xterm-256color";
    EDITOR = "hx";
    FILE_MANAGER = "nemo";

    # Wayland 支持
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    SDL_VIDEODRIVER = "wayland";
  };
}
