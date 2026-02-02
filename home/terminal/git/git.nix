{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.terminal.git;
in
{
  options.homeModules.terminal.git = {
    enable = lib.mkEnableOption "Git version control system";

    user-name = lib.mkOption {
      type = lib.types.str;
      default = "ErodeesFleurs";
      description = "Git user name";
    };

    user-email = lib.mkOption {
      type = lib.types.str;
      default = "862959461@qq.com";
      description = "Git user email";
    };

    signing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable commit signing";
      };

      key = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "GPG key ID for signing";
      };

      sign-by-default = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Sign commits by default";
      };
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        lg = "log --graph --oneline --decorate --all";
      };
      description = "Git command aliases";
    };

    extra-config = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional git configuration";
      example = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };

    delta = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable delta syntax highlighter";
      };

      options = lib.mkOption {
        type = lib.types.attrs;
        default = {
          navigate = true;
          light = false;
          side-by-side = true;
        };
        description = "Delta configuration options";
      };
    };

    lfs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Git LFS support";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;

      # Use the new settings API
      settings = lib.mkMerge [
        {
          # User settings
          user = {
            name = cfg.user-name;
            email = cfg.user-email;
          };

          # Core settings
          core = {
            editor = "hx";
            autocrlf = "input";
          };

          # Default branch
          init = {
            defaultBranch = "main";
          };

          # Pull strategy
          pull = {
            rebase = false;
          };

          # Push settings
          push = {
            default = "simple";
          };

          # Aliases
          alias = cfg.aliases;
        }
        (lib.mkIf cfg.signing.enable {
          user.signingkey = cfg.signing.key;
          commit.gpgsign = cfg.signing.sign-by-default;
        })
        cfg.extra-config
      ];

      lfs = lib.mkIf cfg.lfs.enable {
        enable = true;
      };
    };

    programs.delta = lib.mkIf cfg.delta.enable {
      enable = true;
      options = cfg.delta.options;
    };
  };
}
