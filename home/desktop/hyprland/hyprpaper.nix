{ lib, ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = lib.mkForce {
        monitor = "";
        path = "${../../../assets/wallpaper.jpg}";
        fit_mode = "cover";
      };

      ipc = true;
      splash = true;
      splash_offset = 20;
      splash_opacity = 0.8;
    };
  };
}
