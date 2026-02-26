{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.zed;
in
{
  options.homeModules.zed = {
    enable = lib.mkEnableOption "Zed editor";

    userSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional user settings to merge";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extraPackages = with pkgs; [
        package-version-server
        vscode-json-languageserver

        lua-language-server
        emmylua-ls

        nil
        nixd

        ty
        basedpyright
        ruff

        rust-analyzer
        zls
      ];
      extensions = [
        "dockerfile"
        "make"
        "emmylua"
        "git-firefly"
        "html"
        "lua"
        "neocmake"
        "nix"
        "nu"
        "opencode"
        "toml"
        "zig"
      ];

      userSettings = lib.mkMerge [
        {
          auto_signature_help = false;
          auto_update = false;

          diagnostics = {
            inline = {
              enabled = true;
            };
          };

          inlay_hints = {
            enabled = true;
          };

          agent = {
            inline_assistant_model = {
              provider = "copilot_chat";
              model = "gpt-5-mini";
            };
            default_profile = "write";
            default_model = {
              provider = "copilot_chat";
              model = "claude-sonnet-4.5";
            };
            model_parameters = [ ];
          };

          lsp = with pkgs; {
            rust-analyzer = {
              initialization_options = {
                check = {
                  command = "clippy";
                };
              };

              binary = {
                path = lib.getExe rust-analyzer;
              };
            };
            nil = {
              binary = {
                path = lib.getExe nil;
              };
            };
            nixd = {
              binary = {
                path = lib.getExe nixd;
              };
            };
            json-language-server = {
              binary = {
                path = lib.getExe vscode-json-languageserver;
                arguments = [ "--stdio" ];
              };
            };
            lua-language-server = {
              binary = {
                path = lib.getExe lua-language-server;
              };
            };
            emmylua = {
              binary = {
                path = lib.getExe emmylua-ls;
              };
            };
            ruff = {
              binary = {
                path = lib.getExe ruff;
                arguments = [ "server" ];
              };
            };
            ty = {
              binary = {
                path = lib.getExe ty;
                arguments = [ "server" ];
              };
            };
            basedpyright = {
              binary = {
                path = lib.getExe basedpyright;
              };
            };
            zls = {
              binary = {
                path = lib.getExe zls;
              };
              settings = {
                zig_exe_path = lib.getExe zig;
                global_cache_path = "${config.xdg.cacheHome}/zls";
              };
            };
          };

          languages = {
            Python = {
              language_servers = [
                "ruff"
                "ty"
                "!basedpyright"
                "..."
              ];
            };
            Zig = {
              format_on_save = "on";
              language_servers = [
                "zls"
                "..."
              ];
            };
          };

          file_types = {
            "C++" = [
              "cppm"
              "ixx"
            ];
          };

        }
        cfg.userSettings
      ];
    };
  };
}
