{
  config,
  lib,
  pkgs,
  themeLib,
}:

let
  enabled = config.homeModules.dunst.enable;

  mkValueString =
    value:
    if builtins.isBool value then
      lib.boolToString value
    else if builtins.isInt value || builtins.isFloat value then
      toString value
    else if builtins.isString value then
      builtins.toJSON value
    else if builtins.isPath value then
      builtins.toJSON (toString value)
    else if builtins.isList value then
      lib.concatMapStringsSep "," mkValueString value
    else
      throw "Unsupported dunst setting value: ${builtins.toJSON value}";

  renderSection = name: values: ''
    [${name}]
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (key: value: "${key} = ${mkValueString value}") values
    )}
  '';

  # 单一数据源：直接复用 homeModules.dunst.settings，避免配置漂移
  baseSections = config.homeModules.dunst.settings;

  template = lib.concatStringsSep "\n" (
    lib.mapAttrsToList renderSection (
      lib.recursiveUpdate baseSections {
        global = {
          frame_color = "@outline_variant@";
          highlight = "@primary@";
          separator_color = "frame";
        };

        urgency_low = {
          background = "@surface_container_low@";
          foreground = "@on_surface_variant@";
          frame_color = "@outline_variant@";
        };

        urgency_normal = {
          background = "@surface_container_high@";
          foreground = "@on_surface@";
          frame_color = "@outline_variant@";
        };

        urgency_critical = {
          background = "@error_container@";
          foreground = "@on_error_container@";
          frame_color = "@error@";
        };
      }
    )
  );
in
themeLib.mkColorApp {
  name = "Dunst";
  enable = enabled;
  template = builtins.toFile "dunstrc.monet.in" template;
  themePath = "dunst/dunstrc";
  configPath = ".config/dunst/dunstrc";
  placeholder = true;
  postLink = ''
    ${pkgs.dunst}/bin/dunstctl reload "$SOURCE" 2>/dev/null || ${pkgs.procps}/bin/pkill -HUP dunst 2>/dev/null || true
  '';
}
