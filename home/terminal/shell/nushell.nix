{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.terminal.shell.nushell;
in
{
  options.homeModules.terminal.shell.nushell = {
    enable = lib.mkEnableOption "Nushell shell";

    show-banner = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Show Nushell banner on startup";
    };

    enable-yazi-integration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Yazi file manager integration";
    };

    enable-carapace-integration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Carapace completion integration";
    };

    ssh-auth-sock = lib.mkOption {
      type = lib.types.str;
      default = ''$"($env.XDG_RUNTIME_DIR)/ssh-agent"'';
      description = "SSH agent socket path";
    };

    extra-config = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional Nushell configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nushell = {
      enable = true;

      settings = {
        show_banner = cfg.show-banner;
      };

      extraConfig = ''
        ${lib.optionalString cfg.enable-yazi-integration ''
          # Yazi integration
          def --env y [...args] {
            let tmp = (mktemp -t "yazi-cwd.XXXXXX")
            yazi ...$args --cwd-file $tmp
            let cwd = (open $tmp)
            if $cwd != "" and $cwd != $env.PWD {
              cd $cwd
            }
            rm -fp $tmp
          }
        ''}

        ${lib.optionalString cfg.enable-carapace-integration ''
          # Carapace completion
          let carapace_completer = {|spans: list<string>|
            carapace $spans.0 nushell ...$spans
            | from json
            | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
          }

          let external_completer = {|spans|
            let expanded_alias = scope aliases
            | where name == $spans.0
            | get -o 0.expansion

            let spans = if $expanded_alias != null {
                $spans
                | skip 1
                | prepend ($expanded_alias | split row ' ' | take 1)
            } else {
                $spans
            }

            match $spans.0 {
                _ => $carapace_completer
            } | do $in $spans
          }

          $env.config.completions = {
            external: {
              enable: true
              completer: $external_completer
            }
          }
        ''}

        # SSH agent socket
        $env.SSH_AUTH_SOCK = ${cfg.ssh-auth-sock}

        ${cfg.extra-config}
      '';
    };
  };
}
