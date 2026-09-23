{
  config,
  lib,
  themeLib,
}:

let
  enabled = config.programs.firefox.enable && config.homeModules.firefox.enable-monet;
  profile = config.programs.firefox.profiles.${config.homeModules.firefox.profile-name};
  profileDir = "${config.programs.firefox.profilesPath}/${profile.path}";

  # vars 中间产物按子树生成（后处理在各子树内合并）
  mkVarsTemplates =
    name: source:
    lib.concatMap
      (
        subtree:
        map
          (mode: {
            name = "firefox-${name}-vars-${mode}-${subtree}";
            input = themeLib.materialize {
              inherit source mode;
            };
            output = "${subtree}/firefox/${name}-vars-${mode}.css";
          })
          [
            "light"
            "dark"
          ]
      )
      [
        "light"
        "dark"
      ];
in
{
  enable = enabled;

  templates =
    mkVarsTemplates "userChrome" ./templates/firefox-userChrome-vars.css
    ++ mkVarsTemplates "userContent" ./templates/firefox-userContent-vars.css;

  # 合并：light 变量为基，dark 变量包进 @media，再追加静态样式（按子树执行）
  postSteps = _: ''
    cat "$out/firefox/userChrome-vars-light.css" > "$out/firefox/userChrome.css"
    printf '\n@media (prefers-color-scheme: dark) {\n' >> "$out/firefox/userChrome.css"
    sed 's/^/  /' "$out/firefox/userChrome-vars-dark.css" >> "$out/firefox/userChrome.css"
    printf '}\n\n' >> "$out/firefox/userChrome.css"
    cat ${themeLib.stablePath ./templates/firefox-userChrome.css} >> "$out/firefox/userChrome.css"

    cat "$out/firefox/userContent-vars-light.css" > "$out/firefox/userContent.css"
    printf '\n@media (prefers-color-scheme: dark) {\n' >> "$out/firefox/userContent.css"
    sed 's/^/  /' "$out/firefox/userContent-vars-dark.css" >> "$out/firefox/userContent.css"
    printf '}\n\n' >> "$out/firefox/userContent.css"
    cat ${themeLib.stablePath ./templates/firefox-userContent.css} >> "$out/firefox/userContent.css"

    rm "$out/firefox"/userChrome-vars-*.css "$out/firefox"/userContent-vars-*.css
  '';

  activation =
    themeLib.mkThemeLink {
      name = "FirefoxChrome";
      target = "${profileDir}/chrome/userChrome.css";
      source = "firefox/userChrome.css";
    }
    // themeLib.mkThemeLink {
      name = "FirefoxContent";
      target = "${profileDir}/chrome/userContent.css";
      source = "firefox/userContent.css";
    };
}
