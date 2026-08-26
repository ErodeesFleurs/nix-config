# 系统级程序：游戏、工具、虚拟化
{ pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extest.enable = true;
      gamescopeSession.enable = false;
      protontricks.enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };

    gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general.renice = 10;
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    localsend = {
      enable = true;
      openFirewall = true;
    };

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 3";
      };
      flake = "/home/fleurs/nix-config";
    };

    nix-ld = {
      enable = true;
      libraries = [ ];
    };

    virt-manager.enable = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      swtpm.enable = true;
      runAsRoot = true;
      vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;
  users.groups.libvirtd.members = [ "fleurs" ];
}
