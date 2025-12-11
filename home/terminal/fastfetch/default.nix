{ config, ... }:

{
  # Logo 文件配置
  home.file.".config/fastfetch/logo" = {
    source = ./logo;
    recursive = true;
    executable = true;
  };

  # Fastfetch 程序配置
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        type = "file";
        "source" = "$(ls ${config.home.homeDirectory}/.config/fastfetch/logo/* | shuf -n 1)";
        color = {
          "1" = "magenta";
          "2" = "cyan";
        };
      };

      display = {
        separator = " ";
        color = "cyan";
      };

      modules = [
        {
          type = "custom"; # HardwareStart
          format = "┌─────────────────────── Hardware Information ───────────────────────┐";
        }
        {
          type = "host";
          key = "  󰌢 ";
        }
        {
          type = "cpu";
          key = "   ";
        }
        {
          type = "gpu";
          detectionMethod = "pci";
          key = "   ";
        }
        {
          type = "board";
          key = "  󰚗 ";
        }
        {
          type = "display";
          key = "  󱄄 ";
        }
        {
          type = "memory";
          key = "   ";
        }
        {
          type = "disk";
          key = "   ";
        }
        {
          type = "custom"; # SoftwareStart
          format = "├─────────────────────── Software Information ───────────────────────┤";
        }
        {
          type = "os";
          key = "   ";
        }
        {
          type = "kernel";
          key = "   ";
          format = "{1} {2}";
        }
        {
          type = "wm";
          key = "   ";
        }
        {
          type = "shell";
          key = "   ";
        }
        {
          type = "packages";
          key = "  󰏖 ";
        }
        {
          type = "terminalfont";
          key = "   ";
        }
        {
          type = "processes";
          key = "   ";
        }
        {
          type = "custom";
          format = "|───────────────────────── Uptime / Age ─────────────────────────────|";
        }
        {
          type = "command";
          key = "  OS Age ";
          keyColor = "magenta";
          text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
        }
        {
          type = "uptime";
          key = "  Uptime ";
          keyColor = "magenta";
        }
        {
          type = "custom"; # InformationEnd
          format = "└────────────────────────────────────────────────────────────────────┘";
        }
        {
          type = "colors";
          paddingLeft = 2;
          symbol = "circle";
        }
      ];
    };
  };
}
