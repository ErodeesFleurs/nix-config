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

    enable-server = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable OpenSSH server";
    };

    enable-agent = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to start SSH agent automatically";
    };

    known-hosts = mkOption {
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

    server-settings = mkOption {
      type = types.submodule {
        options = {
          permit-root-login = mkOption {
            type = types.enum [
              "yes"
              "no"
              "prohibit-password"
              "forced-commands-only"
            ];
            default = "prohibit-password";
            description = "Whether root can login via SSH";
          };

          password-authentication = mkOption {
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
      startAgent = cfg.enable-agent;
      knownHosts = cfg.known-hosts;
    };

    services.openssh = mkIf cfg.enable-server {
      enable = true;
      ports = [ cfg.server-settings.port ];
      settings = {
        PermitRootLogin = cfg.server-settings.permit-root-login;
        PasswordAuthentication = cfg.server-settings.password-authentication;
      };
    };

    # 添加 SSH 相关工具
    environment.systemPackages = with pkgs; [
      openssh
    ];
  };
}
