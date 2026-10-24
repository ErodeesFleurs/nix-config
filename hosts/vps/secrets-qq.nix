{ ... }:
{
  age.secrets = {
    vps-qq-config = {
      file = ../../secrets/vps/qq-config.toml.age;
      path = "/etc/qq-agent/config.toml";
      owner = "root";
      group = "qq-agent";
      mode = "0640";
    };
    vps-qq-secrets = {
      file = ../../secrets/vps/qq-secrets.env.age;
      path = "/etc/qq-agent/secrets.env";
      owner = "root";
      group = "root";
      mode = "0600";
    };
    vps-qq-management = {
      file = ../../secrets/vps/qq-management.env.age;
      path = "/etc/qq-agent/management.env";
      owner = "root";
      group = "root";
      mode = "0600";
    };
    vps-qq-model-tunnel = {
      file = ../../secrets/vps/qq-model-tunnel.env.age;
      path = "/etc/qq-agent/model-tunnel.env";
      owner = "root";
      group = "root";
      mode = "0600";
    };
    vps-qq-napcat = {
      file = ../../secrets/vps/qq-napcat.env.age;
      path = "/etc/qq-agent/napcat.env";
      owner = "root";
      group = "root";
      mode = "0600";
    };
  };

  systemd.tmpfiles.rules = [ "d /etc/qq-agent 0750 root qq-agent -" ];

}
