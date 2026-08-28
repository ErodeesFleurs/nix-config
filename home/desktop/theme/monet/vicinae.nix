{
  config,
  lib,
  themeLib,
}:

let
  package = config.programs.vicinae.package;
  vicinae = lib.getExe package;
in
themeLib.mkColorApp {
  name = "Vicinae";
  enable = config.programs.vicinae.enable && package != null;
  template = ./templates/vicinae.toml;
  themePath = "vicinae/themes/monet.toml";
  configPath = ".local/share/vicinae/themes/monet.toml";
  literalsFor = polarity: { variant = polarity; };
  postLink = ''
    ${vicinae} theme set monet >/dev/null 2>&1 || true
  '';
}
