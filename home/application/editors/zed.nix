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

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
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
        "emmylua"
        "nix"
        "toml"
        "nu"
        "git-firefly"
        "neocmake"
        "opencode"
        "gemini"
      ];
      description = "List of Zed extensions to install";
    };

    autoUpdate = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable automatic updates";
    };

    autoSignatureHelp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Show signature help automatically";
    };

    inlayHints = lib.mkOption {
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
      alwaysAllowToolActions = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Always allow agent tool actions";
      };

      modelParameters = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [ ];
        description = "Model parameters for AI agent";
      };
    };

    features = {
      editPredictionProvider = lib.mkOption {
        type = lib.types.str;
        default = "copilot";
        description = "Edit prediction provider (copilot, etc.)";
      };
    };

    lsp = {
      rust = {
        enableClippy = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Use clippy for Rust checking";
        };
      };
    };

    userSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional user settings to merge";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extraPackages = cfg.extraPackages;
      extensions = cfg.extensions;

      userSettings = lib.mkMerge [
        {
          auto_signature_help = cfg.autoSignatureHelp;
          auto_update = cfg.autoUpdate;

          diagnostics = {
            inline = {
              enabled = cfg.diagnostics.inline;
            };
          };

          inlay_hints = {
            enabled = cfg.inlayHints;
          };

          agent = {
            always_allow_tool_actions = cfg.agent.alwaysAllowToolActions;
            model_parameters = cfg.agent.modelParameters;
          };

          features = {
            edit_prediction_provider = cfg.features.editPredictionProvider;
          };

          lsp = lib.mergeAttrsList [
            (lib.mkIf cfg.lsp.rust.enableClippy {
              rust-analyzer = {
                initialization_options = {
                  check = {
                    command = "clippy";
                  };
                };
              };
            })
            {
              rust-analyzer = {
                binary = {
                  path_lookup = true;
                };
              };

              nix = {
                binary = {
                  path_lookup = true;
                };
              };
            }
          ];

        }
        cfg.userSettings
      ];
    };
  };
}
