{ ... }:

{
  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "ghostty";
    EDITOR = "hx";
    FILE_MANAGER = "nemo";

    # Wayland 支持（NIXOS_OZONE_WL 由系统层 hosts/common/desktop.nix 统一设置；
    # WLR_NO_HARDWARE_CURSORS 对 Smithay 的 niri 无效，已删；
    # TERM 由终端自身设置，ghostty 自带完整 terminfo）
    SDL_VIDEODRIVER = "wayland";
  };
}
