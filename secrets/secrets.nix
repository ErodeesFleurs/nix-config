# Auto-generated from README.org
let
  dae = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJb9ab/4suVTwap6zlA2TMv0hfnBJ7WZ94a2lBcKN2Fd agenix_dae";
  vps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILfaH5g1VWv5zZmWJRXQtoxLiy0XJYQF2bIMRQLfzyBW";
in
{
  "config.mihomo.yaml.age".publicKeys = [
    dae
  ];
}
// builtins.listToAttrs (
  map
    (name: {
      name = "vps/${name}";
      value.publicKeys = [
        dae
        vps
      ];
    })
    [
      "root-password.age"
      "qq-config.toml.age"
      "qq-secrets.env.age"
      "qq-management.env.age"
      "qq-model-tunnel.env.age"
      "qq-napcat.env.age"
      "web-outfit-studio-caddyfile.age"
      "web-qq-agent-public-caddyfile.age"
      "web-qq-agent-public-env.age"
      "web-cloud-agent-config.age"
    ]
)
