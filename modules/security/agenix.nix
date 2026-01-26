{ config, lib, ... }:
let
  cfg = config.modules.security.agenix;
in
{
  options.modules.security.agenix = {
    identity-paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "~/.ssh/id_ed25519" ];
      description = "List of paths to search for agenix identity files.";
    };
  };

}
