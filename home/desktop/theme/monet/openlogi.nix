{
  config,
  themeLib,
}:

let
  mkObjInput =
    mode:
    themeLib.materialize {
      source = ./templates/openlogi-theme.json;
      inherit mode;
      literals = {
        theme_name = "Monet MD3 ${if mode == "dark" then "Dark" else "Light"}";
        inherit mode;
      };
    };

  # Each subtree carries both explicit choices. Only this metadata follows
  # current: the standalone Actions Ring uses it to resolve System appearance.
  mkThemeSet =
    subtree:
    builtins.toFile "openlogi-${subtree}.matugen.json" ''
      {
        "name": "Monet MD3",
        "author": "matugen",
        "appearance": "${subtree}",
        "themes": [
          <* include "openlogi-light-obj" *>,
          <* include "openlogi-dark-obj" *>
        ]
      }
    '';
in
themeLib.mkApp {
  enable = config.homeModules.openlogi.enable;

  templates = [
    {
      name = "openlogi-light-obj";
      input = mkObjInput "light";
    }
    {
      name = "openlogi-dark-obj";
      input = mkObjInput "dark";
    }
  ]
  ++
    map
      (subtree: {
        name = "openlogi-${subtree}";
        input = mkThemeSet subtree;
        output = "${subtree}/openlogi/monet.json";
      })
      [
        "light"
        "dark"
      ];

  # Keep the link aimed at current, never its resolved store target: a Darkman
  # mode change is an atomic link flip, not a config rewrite or app restart.
  links = [
    {
      name = "OpenLogi";
      target = ".config/openlogi/monet.json";
      source = "openlogi/monet.json";
      # On first enable, the generated palette is installed by linkGeneration.
      after = [
        "initThemeLinks"
        "cleanupDarkmanLegacyHooks"
        "linkGeneration"
      ];
    }
  ];
}
