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

  # 把 @token@ 源模板物化为 matugen 原生语法模板（{{ colors.<role>.<mode>.<format> }}）。
  # - literals：eval 期已知的字面 token（字体名、home 目录、主题名等）
  # - mode：颜色引用的模式（default 跟随 matugen -m；light/dark 用于双渲染 app）
  materialize =
    {
      source,
      mode ? "default",
      literals ? { },
    }:
    let
      literalSeds = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (token: value: ''
          sed -i 's|@${token}@|${value}|g' "$out"
        '') literals
      );
    in
    pkgs.runCommand
      "matugen-tpl-${builtins.unsafeDiscardStringContext (builtins.baseNameOf (toString source))}-${mode}"
      { }
      ''
        cp ${stablePath source} "$out"
        ${literalSeds}
        sed -E -i \
          -e 's/@([a-z_]+)_rgb@/{{colors.\1.${mode}.hex_stripped}}/g' \
          -e 's/@([a-z_]+)@/{{colors.\1.${mode}.hex}}/g' \
          "$out"
      '';

  # 由 template 条目列表生成 matugen config.toml。
  # output_path 为相对路径（从 config.toml 所在目录解析），
  # 因此同一份 config 放在不同 $out 根目录即可用于两个 polarity。
  mkMatugenConfig =
    entries:
    pkgs.writeTextFile {
      name = "matugen-config.toml";
      text = ''
        [config]
        version_check = false
        caching = false
      ''
      + lib.concatMapStringsSep "\n" (e: ''
        [templates."${e.name}"]
        input_path = "${e.input}"
        ${lib.optionalString (e ? output) ''output_path = "${e.output}"''}
      '') entries;
    };
in
rec {
  inherit
    homeDir
    currentSymlink
    mkThemeLink
    mkXdgPlaceholder
    stablePath
    reloadScripts
    materialize
    ;

  mkApp =
    {
      enable,
      outputDirs,
      templates ? [ ],
      postSteps ? (_: ""),
      links ? [ ],
      xdgPlaceholders ? [ ],
      activation ? { },
      xdgConfig ? { },
    }:
    {
      inherit
        enable
        outputDirs
        templates
        postSteps
        ;
      activation = activation // mergeAttrs (map mkThemeLink links);
      xdgConfig = xdgConfig // mergeAttrs (map mkXdgPlaceholder xdgPlaceholders);
    };

  # 单模板应用的构造器：从 themePath/configPath 推导 outputDirs、activation
  # 链接与 xdg 占位符，模板经 materialize 转为 matugen 语法。
  # configPath 为 null 时表示不创建链接（如 discord，经 current 软链消费）。
  mkColorApp =
    {
      name,
      enable,
      template,
      themePath,
      configPath ? null,
      mode ? "default",
      literals ? { },
      placeholder ? false,
      placeholderText ? "# Managed by Monet theme activation\n",
      postLink ? "",
      postSteps ? (_: ""),
    }:
    mkApp {
      inherit enable postSteps;
      outputDirs = [ "$out/${builtins.dirOf themePath}" ];
      templates = [
        {
          name = lib.toLower name;
          input = materialize {
            source = template;
            inherit mode literals;
          };
          output = themePath;
        }
      ];
      xdgPlaceholders = lib.optional placeholder {
        path = lib.removePrefix ".config/" configPath;
        text = placeholderText;
      };
      links = lib.optional (configPath != null) {
        inherit name postLink;
        target = configPath;
        source = themePath;
      };
    };

  collect =
    apps:
    let
      enabledApps = builtins.filter (app: app.enable) apps;
      outputDirs = lib.concatMap (app: app.outputDirs) enabledApps;
      # templates 可以是列表（polarity 无关）或函数（按 polarity 产出条目，如 icons）
      templatesFor =
        polarity:
        lib.concatMap (
          app:
          let
            t = app.templates or [ ];
          in
          if builtins.isFunction t then t { inherit polarity; } else t
        ) enabledApps;
    in
    {
      inherit outputDirs templatesFor;

      createOutputDirs = lib.concatMapStringsSep "\n" (dir: "mkdir -p ${dir}") outputDirs;

      configToml = polarity: mkMatugenConfig (templatesFor polarity);

      generate =
        { polarity }:
        lib.concatStringsSep "\n" (map (app: (app.postSteps or (_: "")) { inherit polarity; }) enabledApps);

      activation = mergeAttrs (map (app: app.activation or { }) enabledApps);
      xdgConfig = mergeAttrs (map (app: app.xdgConfig or { }) enabledApps);
    };
}
