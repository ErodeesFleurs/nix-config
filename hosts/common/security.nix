# 安全：sudo-rs、polkit、agenix
{ ... }:

{
  security = {
    polkit.enable = true;
    sudo.enable = false;
    sudo-rs = {
      enable = true;
      wheelNeedsPassword = true;
      extraRules = [ ];
    };
  };

  age = {
    identityPaths = [
      "/home/fleurs/.ssh/id_ed25519"
      "/home/fleurs/.ssh/dae_ed25519"
    ];
    secrets = {
      "config.mihomo.yaml" = {
        file = ../../secrets/config.mihomo.yaml.age;
      };
    };
  };
}
