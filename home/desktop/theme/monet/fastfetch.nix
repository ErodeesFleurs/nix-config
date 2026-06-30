{ config, themeLib }:

let
  enabled = config.programs.fastfetch.enable;
  inherit (themeLib) homeDir;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/fastfetch" ];

  generate =
    { polarity }:
    ''
      jq -r '
        def c($name): .colors[$name]["${polarity}"].color;
        [
          "{",
          "  \"$schema\": \"https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json\",",
          "  \"display\": {",
          "    \"separator\": \" \",",
          "    \"color\": \"" + c("primary") + "\"",
          "  },",
          "  \"logo\": {",
          "    \"type\": \"file\",",
          "    \"source\": \"$(ls ${homeDir}/.config/fastfetch/logo/* | shuf -n 1)\",",
          "    \"color\": {",
          "      \"1\": \"" + c("primary") + "\",",
          "      \"2\": \"" + c("tertiary") + "\"",
          "    }",
          "  },",
          "  \"modules\": [",
          "    {",
          "      \"type\": \"custom\",",
          "      \"format\": \"┌─────────────────────── Hardware Information ───────────────────────┐\"",
          "    },",
          "    { \"type\": \"host\", \"key\": \"  󰌢 \" },",
          "    { \"type\": \"cpu\", \"key\": \"   \" },",
          "    { \"type\": \"gpu\", \"detectionMethod\": \"pci\", \"key\": \"   \" },",
          "    { \"type\": \"board\", \"key\": \"  󰚗 \" },",
          "    { \"type\": \"display\", \"key\": \"  󱄄 \" },",
          "    { \"type\": \"memory\", \"key\": \"   \" },",
          "    { \"type\": \"disk\", \"key\": \"   \" },",
          "    {",
          "      \"type\": \"custom\",",
          "      \"format\": \"├─────────────────────── Software Information ───────────────────────┤\"",
          "    },",
          "    { \"type\": \"os\", \"key\": \"   \" },",
          "    { \"type\": \"kernel\", \"key\": \"   \", \"format\": \"{1} {2}\" },",
          "    { \"type\": \"wm\", \"key\": \"   \" },",
          "    { \"type\": \"shell\", \"key\": \"   \" },",
          "    { \"type\": \"packages\", \"key\": \"  󰏖 \" },",
          "    { \"type\": \"terminalfont\", \"key\": \"   \" },",
          "    { \"type\": \"processes\", \"key\": \"   \" },",
          "    {",
          "      \"type\": \"custom\",",
          "      \"format\": \"|───────────────────────── Uptime / Age ─────────────────────────────|\"",
          "    },",
          "    {",
          "      \"type\": \"command\",",
          "      \"key\": \"  OS Age \",",
          "      \"keyColor\": \"" + c("tertiary") + "\",",
          "      \"text\": \"birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days\"",
          "    },",
          "    {",
          "      \"type\": \"uptime\",",
          "      \"key\": \"  Uptime \",",
          "      \"keyColor\": \"" + c("primary") + "\"",
          "    },",
          "    {",
          "      \"type\": \"custom\",",
          "      \"format\": \"└────────────────────────────────────────────────────────────────────┘\"",
          "    },",
          "    { \"type\": \"colors\", \"paddingLeft\": 2, \"symbol\": \"circle\" }",
          "  ]",
          "}"
        ] | .[]
      ' colors.json > "$out/fastfetch/config.jsonc"
    '';

  links = [
    {
      name = "Fastfetch";
      target = ".config/fastfetch/config.jsonc";
      source = "fastfetch/config.jsonc";
    }
  ];
}
