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
          # 原子替换：先建临时链接再 rename，消除 rm+ln 之间文件不存在的窗口
          # （waybar reload_style_on_change 曾在该窗口读到空样式而整栏透明化）
          $DRY_RUN_CMD ln -sfn "$SOURCE" "$TARGET.tmp"
          $DRY_RUN_CMD mv -T "$TARGET.tmp" "$TARGET"
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
        templates
        postSteps
        ;
      activation = activation // mergeAttrs (map mkThemeLink links);
      xdgConfig = xdgConfig // mergeAttrs (map mkXdgPlaceholder xdgPlaceholders);
    };

  # 单模板应用的构造器：每个模板生成 light/ dark 两棵子树的条目，
  # 从 themePath/configPath 推导 activation 链接与 xdg 占位符。
  # configPath 为 null 时表示不创建链接（如 discord，经 current 软链消费）。
  mkColorApp =
    {
      name,
      enable,
      template,
      themePath,
      configPath ? null,
      literals ? { },
      # 按 polarity 变化的字面替换（如 vicinae 的 variant）
      literalsFor ? (_: { }),
      placeholder ? false,
      placeholderText ? "# Managed by Monet theme activation\n",
      postLink ? "",
      postSteps ? (_: ""),
    }:
    mkApp {
      inherit enable postSteps;
      templates =
        map
          (polarity: {
            name = "${lib.toLower name}-${polarity}";
            input = materialize {
              source = template;
              mode = polarity;
              literals = literals // literalsFor polarity;
            };
            output = "${polarity}/${themePath}";
          })
          [
            "light"
            "dark"
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
      # 所有条目带 light/ dark/ 子树前缀，一次 matugen 运行渲染两个主题
      templates = lib.concatMap (app: app.templates or [ ]) enabledApps;

      subtreeEntries = polarity: builtins.filter (e: lib.hasPrefix "${polarity}/" e.output) templates;
    in
    {
      inherit templates;

      # 同一壁纸时：单 config 一次渲染全部
      configToml = mkMatugenConfig templates;
      # 壁纸不同时：按子树拆分的 config（每个壁纸一次运行）
      configTomlFor = polarity: mkMatugenConfig (subtreeEntries polarity);

      generate =
        { polarity }:
        lib.concatStringsSep "\n" (map (app: (app.postSteps or (_: "")) { inherit polarity; }) enabledApps);

      activation = mergeAttrs (map (app: app.activation or { }) enabledApps);
      xdgConfig = mergeAttrs (map (app: app.xdgConfig or { }) enabledApps);
    };
}
