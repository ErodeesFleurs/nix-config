{
  config,
  lib,
  ...
}:

let
  cfg = config.homeModules.keyring.gnome;
in
{
  options.homeModules.keyring.gnome = {
    enable = lib.mkEnableOption "GNOME Keyring for credential storage";

    components = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "pkcs11"
        "secrets"
        "ssh"
      ];
      description = "Components to enable in GNOME Keyring";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gnome-keyring = {
      enable = true;
      components = cfg.components;
    };
  };
}
