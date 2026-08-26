{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.network.ssh;
in
{
  options.modules.network.ssh = {
    enable = lib.mkEnableOption "SSH client and server support";

    enable-server = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable OpenSSH server";
    };

    enable-agent = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to start SSH agent automatically";
    };

    known-hosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            publicKey = lib.mkOption {
              type = lib.types.str;
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

    server-settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          permit-root-login = lib.mkOption {
            type = lib.types.enum [
              "yes"
              "no"
              "prohibit-password"
              "forced-commands-only"
            ];
            default = "prohibit-password";
            description = "Whether root can login via SSH";
          };

          password-authentication = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to allow password authentication";
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 22;
            description = "SSH server port";
          };
        };
      };
      default = { };
      description = "OpenSSH server configuration options";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      startAgent = cfg.enable-agent;
      knownHosts = cfg.known-hosts;
    };

    services.openssh = lib.mkIf cfg.enable-server {
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
