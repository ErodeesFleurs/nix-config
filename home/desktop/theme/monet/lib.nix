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

  normalizeReplacement =
    replacement:
    if builtins.isString replacement then
      {
        placeholder = replacement;
        color = replacement;
        transform = "hex";
      }
    else
      {
        transform = "hex";
      }
      // replacement;

  colorFilter =
    polarity:
    {
      color,
      transform,
      ...
    }:
    let
      raw = ''.colors.${color}["${polarity}"].color'';
    in
    ({
      hex = raw;
      noHash = ''${raw} | ltrimstr("#")'';
    }).${transform};

  mkSubstituteArg =
    polarity:
    replacement:
    let
      normalized = normalizeReplacement replacement;
    in
    "--replace-fail ${lib.escapeShellArg "@${normalized.placeholder}@"} \"$(jq -r ${
      lib.escapeShellArg (colorFilter polarity normalized)
    } colors.json)\"";

  mkLiteralSubstituteArg =
    {
      placeholder,
      value,
    }:
    "--replace-fail ${lib.escapeShellArg "@${placeholder}@"} ${lib.escapeShellArg value}";
in
{
  inherit homeDir currentSymlink mkThemeLink mkXdgPlaceholder;

  renderTemplate =
    {
      source,
      target,
      polarity,
      colors ? [ ],
      replacements ? [ ],
      literalReplacements ? [ ],
      append ? [ ],
    }:
    let
      allReplacements = (map normalizeReplacement colors) ++ (map normalizeReplacement replacements);
      substituteArgs = lib.concatStringsSep " \\\n        " (
        (map (mkSubstituteArg polarity) allReplacements)
        ++ (map mkLiteralSubstituteArg literalReplacements)
      );
      appendCommands = lib.concatMapStringsSep "\n" (path: "cat ${path} >> \"${target}\"") append;
    in
    ''
      cp ${source} "${target}"
      substituteInPlace "${target}" \
        ${substituteArgs}
      ${appendCommands}
    '';

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
