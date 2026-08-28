{
  config,
  lib,
  pkgs,
  themeLib,
}:

let
  enabled = config.homeModules.mako.enable;

  mkValueString =
    value:
    if builtins.isBool value then
      (if value then "1" else "0")
    else if builtins.isInt value || builtins.isFloat value then
      toString value
    else if builtins.isString value then
      value
    else if builtins.isPath value then
      toString value
    else if builtins.isList value then
      lib.concatMapStringsSep "," mkValueString value
    else
      throw "Unsupported mako setting value: ${builtins.toJSON value}";

  renderKv =
    values:
    lib.concatStringsSep "\n" (lib.mapAttrsToList (key: value: "${key}=${mkValueString value}") values);

  renderSection = name: values: ''
    [${name}]
    ${renderKv values}
  '';

  settings = config.homeModules.mako.settings;
  atoms = lib.filterAttrs (_: v: !builtins.isAttrs v) settings;
  sections = lib.filterAttrs (_: v: builtins.isAttrs v) settings;

  colorOverrides = {
    global = {
      border-color = "@outline_variant@";
      progress-color = "source @primary@";
    };

    "urgency=low" = {
      background-color = "@surface_container_low@";
      text-color = "@on_surface_variant@";
      border-color = "@outline_variant@";
    };

    "urgency=normal" = {
      background-color = "@surface_container_high@";
      text-color = "@on_surface@";
      border-color = "@outline_variant@";
    };

    "urgency=critical" = {
      background-color = "@error_container@";
      text-color = "@on_error_container@";
      border-color = "@error@";
    };
  };

  mergedSections = lib.recursiveUpdate sections (builtins.removeAttrs colorOverrides [ "global" ]);

  template = ''
    ${renderKv (lib.recursiveUpdate atoms colorOverrides.global)}
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: values: renderSection name values) mergedSections
    )}
  '';
in
themeLib.mkColorApp {
  name = "Mako";
  enable = enabled;
  template = builtins.toFile "mako-config.monet.in" template;
  themePath = "mako/config";
  configPath = ".config/mako/config";
  placeholder = true;
  postLink = ''
    ${pkgs.mako}/bin/makoctl reload 2>/dev/null || true
  '';
}
