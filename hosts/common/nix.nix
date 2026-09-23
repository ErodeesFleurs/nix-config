# Nix 子系统设置（GC 由 nh clean 管理，见 programs.nix）
{ inputs, ... }:

{
  nix = {
    # 关闭 legacy channels，nixpkgs 来源统一由 flake.lock 管理
    channel.enable = false;

    # legacy 命令（nix search/run/shell）复用 flake.lock 中的 nixpkgs，
    # 避免每次重新拉取 registry
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];

    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      # 缓存信任由系统声明，不依赖各用户的 flake 信任记录。
      # trusted-users 保留 NixOS 默认的 root；使用这些签名缓存不需要特权。
      substituters = [
        "https://nix-community.cachix.org"
        "https://vicinae.cachix.org"
        "https://fleurs-nur.cachix.org"
        "https://cache.numtide.com"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
        "fleurs-nur.cachix.org-1:pmeJEXCONKeFWIFOVqG2DHMQYR87VRSmwESRy55Wt7M="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];

      # 配置仓库总是 dirty，该警告纯噪音
      warn-dirty = false;

      # 默认 64M 缓冲区在大包下载时经常溢出告警并降速
      download-buffer-size = 268435456;

      # 写入 store 时即时硬链接去重（替代周期性全店扫描）
      auto-optimise-store = true;

      # 两台主机均为 tmpfs 根（impermanence）：大型构建若落在 /tmp 会受
      # 50% RAM 上限约束。用 nix 标准构建目录：父链全是 root 0755，
      # 不会有 world-writable 检查问题（/var/tmp 会触发）。
      build-dir = "/nix/var/nix/builds";
    };
  };

  systemd.tmpfiles.rules = [
    "d /nix/var/nix/builds 0755 root root -"
    # channels 已禁用（channel.enable=false），清理历史遗留目录，
    # 消除每次 activation 的 channels 警告（impermanence 下 /persist/root 持久，不会自愈）
    "r /root/.nix-defexpr/channels - - - - -"
    "r /home/fleurs/.nix-defexpr/channels - - - - -"
    "r /nix/var/nix/profiles/per-user/root/channels - - - - -"
    "r /nix/var/nix/profiles/per-user/root/channels-1-link - - - - -"
  ];
}
