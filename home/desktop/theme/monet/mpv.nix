{ config, themeLib }:

themeLib.mkColorApp {
  name = "Mpv";
  enable = config.programs.mpv.enable;
  template = ./templates/mpv.conf;
  themePath = "mpv/monet.conf";
  configPath = ".config/mpv/monet.conf";
}
