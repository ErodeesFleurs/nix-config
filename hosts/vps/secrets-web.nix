{ config, ... }:
{
  # Only ciphertext enters the store; keep the applications' existing paths and
  # access modes. Caddy certificates, releases and progress data remain external.
  age.secrets = {
    vps-outfit-studio-caddyfile = {
      file = ../../secrets/vps/web-outfit-studio-caddyfile.age;
      path = "/etc/outfit-studio/Caddyfile";
      owner = "root";
      group = "root";
      mode = "0644";
    };
    vps-qq-agent-public-caddyfile = {
      file = ../../secrets/vps/web-qq-agent-public-caddyfile.age;
      path = "/etc/qq-agent-public/Caddyfile";
      owner = "root";
      group = "qq-agent-public";
      mode = "0640";
    };
    vps-qq-agent-public-env = {
      file = ../../secrets/vps/web-qq-agent-public-env.age;
      path = "/etc/qq-agent-public/public.env";
      owner = "root";
      group = "root";
      mode = "0600";
    };
    vps-cloud-agent-config = {
      file = ../../secrets/vps/web-cloud-agent-config.age;
      path = "/usr/local/cloud-agent/config.yaml";
      owner = "root";
      group = "root";
      mode = "0644";
    };
  };

  systemd.tmpfiles.rules = [
    "d /etc/outfit-studio 0755 root root -"
    "d /etc/qq-agent-public 0750 root qq-agent-public -"
    "d /usr/local/cloud-agent 0755 root root -"
  ];

  # The provider binary remains outside the store. Its optional
  # /etc/sysconfig/cloud-agent environment file was absent during migration.
  systemd.services.cloud-agent.restartTriggers = [ config.age.secrets.vps-cloud-agent-config.file ];
}
