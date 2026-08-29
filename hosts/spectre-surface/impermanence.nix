# Impermanence：tmpfs 根 + /persist 绑定（V1 零迁移）
#
# 布局：/ 为 tmpfs（重启即清空），/persist 挂载原根分区作为持久 backing。
# 所有绑定源即磁盘上的现有目录（/persist/nix 即原 /nix），无需任何数据迁移；
# 回滚旧 generation 即完全恢复原布局（分区内容未动）。
#
# 临时化目录：/tmp、/srv、/usr、/mnt、/opt 及根下杂项。
# /etc 已由 modules.etc 的不可变 overlay 管理，NM 连接等经 /persist/etc 绑定（见 wlan/dae 模块）。
{ ... }:

{
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=50%"
        "mode=755"
      ];
    };

    # store 与 nix db（stage 2 init 位于 store，initrd 即需）
    "/nix" = {
      device = "/persist/nix";
      fsType = "none";
      options = [ "bind" ];
      neededForBoot = true;
      noCheck = true;
    };

    # 系统状态：journal、bluetooth 配对、cups、uid/gid 映射、swapfile 等
    "/var" = {
      device = "/persist/var";
      fsType = "none";
      options = [ "bind" ];
      neededForBoot = true;
      noCheck = true;
    };

    # 用户数据（整体持久）
    # neededForBoot：agenix 在 local-fs 之前解密 secret，identity 在 ~fleurs/.ssh 下
    "/home" = {
      device = "/persist/home";
      fsType = "none";
      options = [ "bind" ];
      neededForBoot = true;
      noCheck = true;
    };

    # root 家目录（nix profile 等）
    "/root" = {
      device = "/persist/root";
      fsType = "none";
      options = [ "bind" ];
      noCheck = true;
    };
  };

  # 大型构建移出 tmpfs 根（/tmp 在内存中，50% RAM 上限）。
  # 用 nix 标准构建目录：父链全是 root 0755，不会有 world-writable 检查问题。
  nix.settings.build-dir = "/nix/var/nix/builds";
  systemd.tmpfiles.rules = [
    "d /nix/var/nix/builds 0755 root root -"
  ];
}
