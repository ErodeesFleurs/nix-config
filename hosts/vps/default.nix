# This host reuses the existing ext4 root and EFI partition; never format them.
{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./users-ids.nix
    ./users.nix
    ./secrets.nix
    ./services-qq.nix
    ./services-web.nix
  ];

  networking = {
    hostName = "vps";
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = true;
      # Public SSH and HTTPS only; the Hong Kong host uses direct egress.
      allowedTCPPorts = [
        22
        80
        443
        8443
        8444
      ];
      allowedUDPPorts = [
        443
        8443
        8444
      ];
    };
  };
  systemd.network = {
    enable = true;
    links."10-wan" = {
      matchConfig.MACAddress = "7c:d3:0a:ec:e8:2c";
      linkConfig.Name = "wan";
    };
    networks."10-wan" = {
      matchConfig.Name = "wan";
      address = [ "198.44.178.249/24" ];
      routes = [ { Gateway = "198.44.178.1"; } ];
      dns = [
        "8.8.8.8"
        "1.1.1.1"
      ];
      networkConfig = {
        DHCP = "no";
        IPv6AcceptRA = false;
        LinkLocalAddressing = "ipv6";
      };
    };
  };
  services.resolved.enable = true;
  time.timeZone = "Asia/Shanghai";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  nix = {
    channel.enable = false;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = 1;
      cores = 12;
      build-dir = "/nix/var/nix/builds";
      auto-optimise-store = true;
    };
  };
  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "20G";
    MemoryMax = "24G";
    CPUQuota = "1200%";
  };
  systemd.tmpfiles.rules = [ "d /nix/var/nix/builds 0755 root root -" ];

  # Retain the provider's existing static management agent and external config.
  systemd.services.cloud-agent = {
    description = "Rain cloud agent service";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      bash
      coreutils
      iproute2
      procps
      systemd
      util-linux
    ];
    unitConfig.ConditionFileIsExecutable = "/usr/local/cloud-agent/cloud-agent";
    startLimitIntervalSec = 5;
    startLimitBurst = 10;
    serviceConfig = {
      ExecStart = "/usr/local/cloud-agent/cloud-agent service";
      EnvironmentFile = "-/etc/sysconfig/cloud-agent";
      Restart = "always";
      RestartSec = 120;
    };
  };

  services.smartd.enable = true;
  services.fstrim.enable = true;
  environment.systemPackages = with pkgs; [
    curl
    file
    git
    htop
    jq
    pciutils
    python3
    rsync
    starship
    tmux
  ];

  system.stateVersion = "26.05";
}
