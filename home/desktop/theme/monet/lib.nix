{
  config,
  lib,
  pkgs,
}:

let
  homeDir = config.home.homeDirectory;
  currentSymlink = "${homeDir}/.local/share/themes/current";

  toHomePath = path: if lib.hasPrefix "/" path then path else "${homeDir}/${path}";

  mkThemeLink =
    {
      name,
      target,
      source,
      after ? [
        "initThemeLinks"
        "cleanupDarkmanLegacyHooks"
      ],
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

  mergeColorTokens = lists: lib.unique (lib.concatLists lists);

  terminalColorTokens = [
    "surface_container_low"
    "on_surface"
    "on_surface_variant"
    "primary"
    "on_primary_container"
    "secondary"
    "on_secondary_container"
    "tertiary"
    "on_tertiary_container"
    "error"
    "on_error_container"
    "outline"
  ];

  normalizeReplacement =
    replacement:
    if builtins.isString replacement then
      {
        token = replacement;
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
    builtins.getAttr transform {
      hex = raw;
      noHash = ''${raw} | ltrimstr("#")'';
    };

  mkSubstituteArg =
    polarity: replacement:
    let
      normalized = normalizeReplacement replacement;
    in
    "--replace-fail ${lib.escapeShellArg "@${normalized.token}@"} \"$(jq -r ${lib.escapeShellArg (colorFilter polarity normalized)} colors.json)\"";

  mkLiteralSubstituteArg =
    {
      token,
      value,
    }:
    "--replace-fail ${lib.escapeShellArg "@${token}@"} ${lib.escapeShellArg value}";

  # 把仓库内文件复制为独立 store 路径（按内容寻址）。
  # 直接引用 flake 源码树的子路径会导致任何仓库改动都改变路径字符串，
  # 从而触发所有主题派生的无谓重建。
  stablePath =
    path:
    builtins.path {
      inherit path;
      # unsafeDiscardStringContext：name 仅是输出路径的标签，
      # 内容引用由 path 参数携带（toFile 产物的 basename 自带 hash，需剥离 context）
      name = builtins.unsafeDiscardStringContext (builtins.baseNameOf (toString path));
    };

  # 主题切换时的运行时重载脚本（darkman hook 与各应用 activation postLink 共用）
  reloadScripts = {
    # Waybar — USR2 触发样式重载
    waybar = ''
      ${pkgs.procps}/bin/pkill -SIGUSR2 waybar 2>/dev/null || true
    '';

    # Fcitx5 — 重载 classicui addon（候选框主题属于该 addon）
    fcitx5 = ''
      if ${pkgs.glib}/bin/gdbus call \
        --session \
        --dest org.freedesktop.DBus \
        --object-path /org/freedesktop/DBus \
        --method org.freedesktop.DBus.NameHasOwner \
        org.fcitx.Fcitx5 \
        | ${pkgs.gnugrep}/bin/grep -q '(true,)'; then
        ${pkgs.glib}/bin/gdbus call \
          --session \
          --dest org.fcitx.Fcitx5 \
          --object-path /controller \
          --method org.fcitx.Fcitx.Controller1.ReloadAddonConfig \
          classicui >/dev/null 2>&1 \
          || ${pkgs.fcitx5}/bin/fcitx5-remote -r >/dev/null 2>&1 \
          || true
      fi
    '';
  };
in
{
  inherit
    homeDir
    currentSymlink
    mergeColorTokens
    mkThemeLink
    mkXdgPlaceholder
    terminalColorTokens
    stablePath
    reloadScripts
    ;

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
        (map (mkSubstituteArg polarity) allReplacements) ++ (map mkLiteralSubstituteArg literalReplacements)
      );
      appendCommands = lib.concatMapStringsSep "\n" (
        path: "cat ${stablePath path} >> \"${target}\""
      ) append;
    in
    ''
      cp ${stablePath source} "${target}"
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
