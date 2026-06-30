{ config, lib }:

let
  homeDir = config.home.homeDirectory;
  currentSymlink = "${homeDir}/.local/share/themes/current";

  toHomePath =
    path:
    if lib.hasPrefix "/" path then
      path
    else
      "${homeDir}/${path}";

  mkThemeLink =
    {
      name,
      target,
      source,
      after ? [ "initThemeLinks" "cleanupDarkmanLegacyHooks" ],
      postLink ? "",
      activationName ? "link${name}Theme",
    }:
    {
      ${activationName} = lib.hm.dag.entryAfter after ''
        TARGET=${lib.escapeShellArg (toHomePath target)}
        SOURCE=${lib.escapeShellArg "${currentSymlink}/${source}"}

        if [ -f "$SOURCE" ]; then
          $DRY_RUN_CMD mkdir -p "$(dirname "$TARGET")"
          $DRY_RUN_CMD rm -f "$TARGET"
          $DRY_RUN_CMD ln -sfn "$SOURCE" "$TARGET"
          ${postLink}
        fi
      '';
    };

  mkXdgPlaceholder =
    {
      path,
      text ? "# Managed by Monet theme activation\n",
    }:
    {
      ${path} = {
        force = lib.mkForce true;
        inherit text;
      };
    };

  mergeAttrs = lib.foldl' (acc: value: acc // value) { };
in
{
  inherit homeDir currentSymlink mkThemeLink mkXdgPlaceholder;

  mkApp =
    {
      enable,
      outputDirs,
      generate,
      links ? [ ],
      xdgPlaceholders ? [ ],
      activation ? { },
      xdgConfig ? { },
    }:
    {
      inherit enable outputDirs generate;
      activation = activation // mergeAttrs (map mkThemeLink links);
      xdgConfig = xdgConfig // mergeAttrs (map mkXdgPlaceholder xdgPlaceholders);
    };

  collect =
    apps:
    let
      enabledApps = builtins.filter (app: app.enable) apps;
      outputDirs = lib.concatMap (app: app.outputDirs) enabledApps;
    in
    {
      inherit outputDirs;
      createOutputDirs = lib.concatMapStringsSep "\n" (dir: "mkdir -p ${dir}") outputDirs;

      generate =
        { polarity }:
        lib.concatStringsSep "\n" (map (app: app.generate { inherit polarity; }) enabledApps);

      activation = mergeAttrs (map (app: app.activation or { }) enabledApps);
      xdgConfig = mergeAttrs (map (app: app.xdgConfig or { }) enabledApps);
    };
}
