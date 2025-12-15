{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.helix;
in
{
  options.homeModules.helix = {
    enable = lib.mkEnableOption "Helix text editor";

    defaultEditor = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set Helix as the default editor";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        # Nix
        nil
        nixd
        nixfmt

        # AI assistance
        helix-gpt

        # Rust
        rust-analyzer

        # Python
        ruff
        (python313.withPackages (python-pkgs: [
          python-pkgs.python-lsp-ruff
          python-pkgs.python-lsp-server
        ]))

        # Lua
        stylua
        emmylua-ls

        # C/C++
        clang-tools

        # TOML
        taplo

        # Zig
        zls

        # JSON
        vscode-json-languageserver
      ];
      description = "Additional packages to install for Helix (language servers, formatters, etc.)";
    };

    settings = {
      editor = {
        lineNumber = lib.mkOption {
          type = lib.types.str;
          default = "relative";
          description = "Line number display mode (relative, absolute, or none)";
        };

        mouse = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable mouse support";
        };

        cursorline = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Highlight the current line";
        };

        cursorcolumn = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Highlight the current column";
        };

        bufferline = lib.mkOption {
          type = lib.types.str;
          default = "multiple";
          description = "Bufferline display mode";
        };
      };

      lsp = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable LSP support";
        };

        displayMessages = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Display LSP messages";
        };

        displayInlayHints = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Display inlay hints from LSP";
        };

        autoSignatureHelp = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Show signature help automatically";
        };
      };
    };

    languageServers = {
      gpt = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable helix-gpt language server for AI assistance";
        };
      };

      rust = {
        enableClippy = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Use clippy for Rust checking";
        };
      };

      emmylua-ls = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Emmylua language server for Lua support";
        };
      };
    };

    languages = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional language configurations";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;
      defaultEditor = cfg.defaultEditor;
      extraPackages = cfg.extraPackages;

      settings = {
        editor = {
          line-number = cfg.settings.editor.lineNumber;
          mouse = cfg.settings.editor.mouse;
          cursorline = cfg.settings.editor.cursorline;
          cursorcolumn = cfg.settings.editor.cursorcolumn;
          bufferline = cfg.settings.editor.bufferline;

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          statusline = {
            left = [
              "mode"
              "spinner"
            ];
            center = [
              "file-name"
            ];
            right = [
              "diagnostics"
              "selections"
              "position"
              "file-encoding"
              "file-line-ending"
              "file-type"
            ];
            separator = "|";
            mode = {
              normal = "NORMAL";
              insert = "INSERT";
              select = "SELECT";
            };
          };

          lsp = {
            enable = cfg.settings.lsp.enable;
            display-messages = cfg.settings.lsp.displayMessages;
            display-progress-messages = true;
            auto-signature-help = cfg.settings.lsp.autoSignatureHelp;
            display-inlay-hints = cfg.settings.lsp.displayInlayHints;
            display-color-swatches = true;
            display-signature-help-docs = true;
            snippets = true;
            goto-reference-include-declaration = true;
          };
        };
      };

      languages = lib.mkMerge [
        {
          language-server = lib.mkMerge [
            (lib.mkIf cfg.languageServers.gpt.enable {
              gpt = {
                command = "helix-gpt";
                args = [
                  "--handler"
                  "copilot"
                ];
              };
            })
            (lib.mkIf cfg.languageServers.rust.enableClippy {
              rust-analyzer.config.check = {
                command = "clippy";
              };
            })
          ];

          language = [
            {
              name = "c";
              language-servers = [ "clangd" ];
              auto-format = true;
            }
            {
              name = "cpp";
              language-servers = [ "clangd" ];
              auto-format = true;
            }
            {
              name = "nix";
              formatter = {
                command = "nixfmt";
              };
              auto-format = true;
            }
            {
              name = "rust";
              language-servers = [ "rust-analyzer" ] ++ lib.optionals cfg.languageServers.gpt.enable [ "gpt" ];
              auto-format = true;
            }
            {
              name = "python";
              language-servers = [ "pylsp" ] ++ lib.optionals cfg.languageServers.gpt.enable [ "gpt" ];
              formatter = {
                command = "sh";
                args = [
                  "-c"
                  "ruff check --select I --fix - | ruff format --line-length 88 -"
                ];
              };
              auto-format = true;
            }
            {
              name = "lua";
              language-servers = [
                "emmylua-ls"
              ]
              ++ lib.optionals cfg.languageServers.gpt.enable [ "gpt" ];
              formatter = {
                command = "stylua";
                args = [ "-" ];
              };
              auto-format = true;
            }
            {
              name = "toml";
              language-servers = [ "taplo" ];
              auto-format = true;
            }
            {
              name = "zig";
              language-servers = [ "zls" ];
              auto-format = true;
            }
            {
              name = "json";
              language-servers = [ "vscode-json-language-server" ];
              auto-format = true;
            }
          ];
        }
        cfg.languages
      ];
    };
  };
}
