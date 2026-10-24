{
  config,
  lib,
  pkgs,
  ...
}:

{
  # The existing IP certificates use ACME's shortlived profile. Both running
  # Caddy binaries are standard builds (no third-party modules).
  assertions = [
    {
      assertion = lib.versionAtLeast pkgs.caddy.version "2.11.0";
      message = "The VPS IP-certificate Caddyfiles require Caddy >= 2.11.0.";
    }
  ];

  users.groups = {
    outfit-studio.gid = 983;
    qq-agent-public.gid = 980;
  };
  users.users = {
    outfit-studio = {
      isSystemUser = true;
      uid = 983;
      group = "outfit-studio";
      home = "/var/lib/outfit-studio";
    };
    qq-agent-public = {
      isSystemUser = true;
      uid = 980;
      group = "qq-agent-public";
      home = "/var/lib/qq-agent-public";
    };
  };

  # Keep the two Caddy instances separate: they have different users, ACME
  # accounts, challenge listeners and state. Their agenix-managed configuration
  # is decrypted only at activation, never copied into the Nix store as plaintext.
  systemd.services.outfit-studio = {
    description = "Starbound Outfit Studio static HTTPS site";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    restartTriggers = [ config.age.secrets.vps-outfit-studio-caddyfile.file ];
    environment = {
      XDG_DATA_HOME = "/var/lib/outfit-studio";
      XDG_CONFIG_HOME = "/var/lib/outfit-studio/config";
    };
    serviceConfig = {
      Type = "simple";
      User = "outfit-studio";
      Group = "outfit-studio";
      ExecStart = "${pkgs.caddy}/bin/caddy run --config ${config.age.secrets.vps-outfit-studio-caddyfile.path} --adapter caddyfile";
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStopSec = "30s";
      StateDirectory = "outfit-studio";
      StateDirectoryMode = "0700";
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      UMask = "0077";
    };
  };

  systemd.services.qq-agent-public = {
    description = "Dedicated public HTTPS gateway for qq-agent management";
    documentation = [ "https://caddyserver.com/docs/" ];
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    startLimitIntervalSec = 0;
    restartTriggers = [
      config.age.secrets.vps-qq-agent-public-caddyfile.file
      config.age.secrets.vps-qq-agent-public-env.file
    ];
    environment = {
      HOME = "/var/lib/qq-agent-public";
      XDG_DATA_HOME = "/var/lib/qq-agent-public/data";
      XDG_CONFIG_HOME = "/var/lib/qq-agent-public/config";
    };
    serviceConfig = {
      Type = "notify";
      User = "qq-agent-public";
      Group = "qq-agent-public";
      EnvironmentFile = config.age.secrets.vps-qq-agent-public-env.path;
      StateDirectory = "qq-agent-public";
      StateDirectoryMode = "0700";
      WorkingDirectory = "/var/lib/qq-agent-public";
      ExecStart = "${pkgs.caddy}/bin/caddy run --config ${config.age.secrets.vps-qq-agent-public-caddyfile.path} --adapter caddyfile";
      # The existing Caddyfile disables the admin API; restart to apply changes.
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStopSec = "30s";
      UMask = "0077";
      LimitNOFILE = 1048576;
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      SystemCallArchitectures = "native";
    };
  };

  # The previously transient observer is now boot-persistent. Its script uses
  # Python's standard library only, plus systemctl to observe build units.
  # Keep it outside the store: sibling HTML/favicon, capture registry and logs
  # are resolved relative to the original script location.
  systemd.services.osb-progress-auto-web = {
    description = "Automatic OpenStarbound build progress webpage";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.systemd ];
    serviceConfig = {
      Type = "exec";
      User = "root";
      Group = "root";
      ExecStart = "${pkgs.python3}/bin/python3 /root/.local/share/osb-build-progress/build-progress.py --auto --watch-root /root/.local/share/osb-build-progress --log /root/.local/share/osb-build-progress/noexceptions/native-progress.log --port 18888";
    };
  };
}
