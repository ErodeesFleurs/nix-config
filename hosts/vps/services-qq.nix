{
  config,
  lib,
  pkgs,
  ...
}:
let
  napcatImage = "docker.io/mlikiowa/napcat-docker@sha256:132448a544ed5cfa948dff8ae19e80bf4e17896e8ab2ba1c6cbcd86f8ad3e56e";

  # These two administrator-deployed ELFs only need glibc and libgcc_s. Keep
  # /opt out of the store and invoke Nix's loader rather than Debian's /lib64.
  loader = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
  libraryPath = lib.makeLibraryPath [
    pkgs.glibc
    pkgs.stdenv.cc.cc.lib
  ];
  silk = pkgs.writeShellScript "qq-agent-rust-silk" ''
    exec ${loader} --library-path ${libraryPath} /opt/qq-agent/capabilities/rust-silk "$@"
  '';

  # Match the deployed CPU-only decoder, including its bounded workspace.
  cpuLlama = pkgs.llama-cpp.override {
    blasSupport = false;
    cudaSupport = false;
    rocmSupport = false;
    vulkanSupport = false;
  };
  whisper = pkgs.whisper-cpp.override {
    llama-cpp = cpuLlama;
    cudaSupport = false;
    rocmSupport = false;
    vulkanSupport = false;
    withSDL = false;
    withFFmpegSupport = false;
  };

  configPython = pkgs.python3.withPackages (python: [ python.tomli-w ]);
  # Agenix decrypts the source TOML and credentials outside the store. Render
  # only at service start, replacing every old Debian/Nix-profile helper
  # reference with its managed executable.
  renderConfig = pkgs.writeText "qq-agent-runtime-config.py" ''
    import tomllib
    import tomli_w

    with open("/etc/qq-agent/config.toml", "rb") as source:
        config = tomllib.load(source)
    config["extensions"].update({
        "wasmtime_bin": "${pkgs.wasmtime}/bin/wasmtime",
        "tesseract_bin": "${pkgs.tesseract}/bin/tesseract",
        "whisper_bin": "${whisper}/bin/whisper-cli",
        "whisper_model": "/opt/qq-agent/media-models/ggml-tiny.bin",
        "espeak_bin": "${pkgs.espeak-ng}/bin/espeak-ng",
        "ffmpeg_bin": "${pkgs.ffmpeg}/bin/ffmpeg",
        "silk_bin": "${silk}",
    })
    with open("/run/qq-agent/config.toml", "wb") as destination:
        tomli_w.dump(config, destination)
  '';

  hardenedService = {
    Type = "simple";
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    RestrictSUIDSGID = true;
    UMask = "0077";
    RestartSec = 5;
  };
in
{
  users.groups.qq-agent.gid = 982;
  users.users.qq-agent = {
    isSystemUser = true;
    uid = 982;
    group = "qq-agent";
    home = "/home/qq-agent";
    createHome = false;
  };
  users.groups.qq-agent-tunnel.gid = 981;
  users.users.qq-agent-tunnel = {
    isSystemUser = true;
    uid = 981;
    group = "qq-agent-tunnel";
    home = "/var/lib/qq-agent-tunnel";
    createHome = false;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/qq-agent 0755 root root -"
    "d /var/lib/qq-agent/control 0700 qq-agent qq-agent -"
    "d /var/lib/qq-agent/napcat 0755 root root -"
    "d /var/lib/qq-agent/napcat/qq 0700 root root -"
    "d /var/lib/qq-agent/napcat/config 0700 root root -"
    "d /var/lib/qq-agent/napcat/plugins 0700 root root -"
    "d /var/lib/qq-agent-tunnel 0700 qq-agent-tunnel qq-agent-tunnel -"
  ];

  systemd.services.qq-agent = {
    description = "Rust QQ LLM bot";
    wantedBy = [ "multi-user.target" ];
    wants = [
      "network-online.target"
      "qq-agent-napcat.service"
      "qq-agent-model-tunnel.service"
    ];
    after = [
      "network-online.target"
      "qq-agent-napcat.service"
      "qq-agent-model-tunnel.service"
    ];
    startLimitIntervalSec = 0;
    environment.RUST_LOG = "qq_agent=info";
    restartTriggers = [
      "${config.age.secrets.vps-qq-config.file}"
      "${config.age.secrets.vps-qq-secrets.file}"
      "${config.age.secrets.vps-qq-management.file}"
    ];
    serviceConfig = hardenedService // {
      User = "qq-agent";
      Group = "qq-agent";
      WorkingDirectory = "/etc/qq-agent";
      EnvironmentFile = [
        "/etc/qq-agent/secrets.env"
        "/etc/qq-agent/management.env"
      ];
      RuntimeDirectory = "qq-agent";
      RuntimeDirectoryMode = "0700";
      ExecStartPre = "${configPython}/bin/python ${renderConfig}";
      ExecStart = "${loader} --library-path ${libraryPath} /opt/qq-agent/qq-agent /run/qq-agent/config.toml";
      ReadWritePaths = [ "/var/lib/qq-agent/control" ];
      Restart = "on-failure";
      MemoryMax = "512M";
      CPUQuota = "100%";
    };
  };

  systemd.services.qq-agent-model-tunnel = {
    description = "Private SSH tunnel to qq-agent model service";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    startLimitIntervalSec = 0;
    restartTriggers = [ "${config.age.secrets.vps-qq-model-tunnel.file}" ];
    serviceConfig = hardenedService // {
      User = "qq-agent-tunnel";
      Group = "qq-agent-tunnel";
      EnvironmentFile = "/etc/qq-agent/model-tunnel.env";
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.openssh}/bin/ssh -F /dev/null -NT"
        "-o BatchMode=yes -o ExitOnForwardFailure=yes -o IdentitiesOnly=yes"
        "-o StrictHostKeyChecking=yes -o UserKnownHostsFile=/var/lib/qq-agent-tunnel/known_hosts"
        "-o UpdateHostKeys=no -o ServerAliveInterval=30 -o ServerAliveCountMax=3"
        "-i /var/lib/qq-agent-tunnel/id_ed25519"
        "-L 127.0.0.1:21002:127.0.0.1:21002 \${MODEL_SSH_TARGET}"
      ];
      Restart = "always";
      MemoryMax = "64M";
    };
  };

  virtualisation.podman.enable = true;
  # Restore the saved image before starting this unit. --pull=never deliberately
  # preserves the deployed image and avoids an unreviewed network pull on boot.
  systemd.services.qq-agent-napcat = {
    description = "NapCat QQ protocol endpoint for qq-agent";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    startLimitIntervalSec = 0;
    restartTriggers = [ "${config.age.secrets.vps-qq-napcat.file}" ];
    serviceConfig = {
      Type = "simple";
      UMask = "0077";
      ExecStartPre = "-${pkgs.podman}/bin/podman rm --force qq-agent-napcat";
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.podman}/bin/podman run --rm --name qq-agent-napcat --pull=never"
        "--memory 1536m --cpus 2"
        "--env-file /etc/qq-agent/napcat.env"
        "--publish 127.0.0.1:6099:6099 --publish 127.0.0.1:3001:3001"
        "--volume /var/lib/qq-agent/napcat/qq:/app/.config/QQ"
        "--volume /var/lib/qq-agent/napcat/config:/app/napcat/config"
        "--volume /var/lib/qq-agent/napcat/plugins:/app/napcat/plugins"
        napcatImage
      ];
      ExecStop = "${pkgs.podman}/bin/podman stop --ignore --time 20 qq-agent-napcat";
      TimeoutStopSec = 40;
      Restart = "always";
      RestartSec = 5;
      MemoryMax = "1536M";
      CPUQuota = "200%";
    };
  };
}
