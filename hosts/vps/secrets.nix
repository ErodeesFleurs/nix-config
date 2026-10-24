{ lib, ... }:
{
  imports = [
    ./secrets-qq.nix
    ./secrets-web.nix
  ];
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # userborn creates users after decryption; consumers must also wait for the
  # subsequent ownership pass before reading group-restricted configuration.
  systemd.services =
    lib.genAttrs
      [
        "qq-agent"
        "qq-agent-model-tunnel"
        "qq-agent-napcat"
        "qq-agent-public"
        "outfit-studio"
        "cloud-agent"
      ]
      (_: {
        requires = [ "agenix-chown.service" ];
        after = [ "agenix-chown.service" ];
      });
}
