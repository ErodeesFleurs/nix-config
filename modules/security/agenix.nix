{ config, lib, ... }:
let
  cfg = config.modules.security.agenix;
in
{
  options.modules.security.agenix = {
    identity-paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/home/fleurs/.ssh/id_ed25519" ];
      description = "List of paths to search for agenix identity files.";
    };

    secrets = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Path to the directory containing agenix secrets.";
    };
  };

  config = {
    age = {
      identityPaths = cfg.identity-paths;
      secrets = cfg.secrets;
    };
  };
}
