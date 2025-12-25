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

    extra-packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        package-version-server
        vscode-json-languageserver
        lua-language-server
        emmylua-ls
        nil
        nixd
        basedpyright
        ruff
        rust-analyzer
      ];
      description = "Additional packages to install for Zed (language servers, etc.)";
    };

    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
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
      ];
      description = "List of Zed extensions to install";
    };

    auto-update = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable automatic updates";
    };

    auto-signature-help = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Show signature help automatically";
    };

    inlay-hints = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable inlay hints";
    };

    diagnostics = {
      inline = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show diagnostics inline";
      };
    };

    agent = {
      always-allow-tool-actions = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Always allow agent tool actions";
      };

      model-parameters = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [ ];
        description = "Model parameters for AI agent";
      };
    };

    features = {
      edit-prediction-provider = lib.mkOption {
        type = lib.types.str;
        default = "copilot";
        description = "Edit prediction provider (copilot, etc.)";
      };
    };

    lsp = {
      rust = {
        enable-clippy = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Use clippy for Rust checking";
        };
      };
    };

    user-settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional user settings to merge";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extraPackages = cfg.extra-packages;
      extensions = cfg.extensions;

      userSettings = lib.mkMerge [
        {
          auto_signature_help = cfg.auto-signature-help;
          auto_update = cfg.auto-update;

          diagnostics = {
            inline = {
              enabled = cfg.diagnostics.inline;
            };
          };

          inlay_hints = {
            enabled = cfg.inlay-hints;
          };

          agent = {
            always_allow_tool_actions = cfg.agent.always-allow-tool-actions;
            model_parameters = cfg.agent.always-allow-tool-actions;
          };

          features = {
            edit_prediction_provider = cfg.features.edit-prediction-provider;
          };

          lsp = with pkgs; {
            rust-analyzer = lib.mkMerge [
              (lib.mkIf cfg.lsp.rust.enable-clippy {
                initialization_options = {
                  check = {
                    command = "clippy";
                  };
                };
              })
              {
                binary = {
                  path = lib.getExe rust-analyzer;
                  ignore_system_version = false;
                };
              }
            ];
            nix = {
              binary = {
                path = lib.getExe nil;
                ignore_system_version = false;
              };
            };
            json = {
              binary = {
                path = lib.getExe vscode-json-languageserver;
                ignore_system_version = false;
              };
            };
            lua = {
              binary = {
                path = lib.getExe lua-language-server;
                ignore_system_version = false;
              };
            };
            emmylua = {
              binary = {
                path = lib.getExe emmylua-ls;
                ignore_system_version = false;
              };
            };
            python = {
              binary = {
                path = lib.getExe ruff;
                ignore_system_version = false;
              };
            };
          };

        }
        cfg.user-settings
      ];
    };
  };
}
