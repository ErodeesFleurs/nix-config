{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.network.ssh;
in
{
  options.modules.network.ssh = {
    enable = mkEnableOption "SSH client and server support";

    enableServer = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable OpenSSH server";
    };

    enableAgent = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to start SSH agent automatically";
    };

    knownHosts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            publicKey = mkOption {
              type = types.str;
              description = "The public key of the host";
            };
          };
        }
      );
      default = { };
      description = "Known SSH hosts and their public keys";
      example = {
        "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...";
      };
    };

    serverSettings = mkOption {
      type = types.submodule {
        options = {
          permitRootLogin = mkOption {
            type = types.enum [
              "yes"
              "no"
              "prohibit-password"
              "forced-commands-only"
            ];
            default = "prohibit-password";
            description = "Whether root can login via SSH";
          };

          passwordAuthentication = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to allow password authentication";
          };

          port = mkOption {
            type = types.port;
            default = 22;
            description = "SSH server port";
          };
        };
      };
      default = { };
      description = "OpenSSH server configuration options";
    };
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      startAgent = cfg.enableAgent;
      knownHosts = cfg.knownHosts;
    };

    services.openssh = mkIf cfg.enableServer {
      enable = true;
      ports = [ cfg.serverSettings.port ];
      settings = {
        PermitRootLogin = cfg.serverSettings.permitRootLogin;
        PasswordAuthentication = cfg.serverSettings.passwordAuthentication;
      };
    };

    # 添加 SSH 相关工具
    environment.systemPackages = with pkgs; [
      openssh
    ];
  };
}
