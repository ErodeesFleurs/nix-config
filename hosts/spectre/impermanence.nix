# Impermanence：tmpfs 根 + /persist 绑定（V1 零迁移）
#
# 布局：/ 为 tmpfs（重启即清空），/persist 挂载原根分区（ext4）作为持久 backing。
# 所有绑定源即磁盘上的现有目录（/persist/nix 即原 /nix），无需任何数据迁移；
# 回滚旧 generation 即完全恢复原布局（分区内容未动）。
#
# 临时化目录：/tmp、/srv、/usr、/mnt、/opt 及根下杂项。
# /etc 已由 modules.etc 的不可变 overlay 管理，NM 连接等经 /persist/etc 绑定（见 wlan/dae 模块）。
# /media/next（独立数据盘）不受影响，仍按 hardware-configuration.nix 原样挂载。
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

    # 系统状态：journal、bluetooth 配对、cups、uid/gid 映射、libvirtd 等
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

  # build-dir 设置在 hosts/common/nix.nix（两台主机共用）
}
