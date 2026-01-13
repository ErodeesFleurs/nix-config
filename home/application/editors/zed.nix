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
        "html"
        "toml"
        "git-firefly"
        "dockerfile"
        "lua"
        "nix"
        "neocmake"
        "nu"
        "gemini"
        "opencode"
        "emmylua"
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
            always_allow_tool_actions = false;
            model_parameters = [ ];
          };

          features = {
            edit_prediction_provider = "copilot";
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
            json = {
              binary = {
                path = lib.getExe vscode-json-languageserver;
              };
            };
            lua = {
              binary = {
                path = lib.getExe lua-language-server;
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
            biasedpyright = {
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
            "Zig" = {
              format_on_save = "on";
              language_servers = [
                "zls"
                "..."
              ];
            };
          };

        }
        cfg.userSettings
      ];
    };
  };
}
