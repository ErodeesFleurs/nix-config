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
  };

  config = lib.mkIf cfg.enable {
    services.gnome-keyring = {
      enable = true;
      components = [
        "pkcs11"
        "secrets"
        "ssh"
      ];
    };
  };
}
