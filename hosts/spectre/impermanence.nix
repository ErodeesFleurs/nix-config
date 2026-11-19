# Impermanence：tmpfs 根 + Btrfs /persist 绑定
#
# 布局：/ 为 tmpfs（重启即清空），/persist 挂载系统盘 Btrfs 的 @persist 子卷。
# /nix、/var、/home、/root 绑定到 /persist 中的对应目录。
# 文件系统迁移后不能仅靠旧 generation 恢复 ext4；回退依赖独立磁盘副本。
#
# 临时化目录：/tmp、/srv、/usr、/mnt、/opt 及根下杂项。
# /etc 已由 modules.etc 的不可变 overlay 管理，NM 连接等经 /persist/etc 绑定（见 wlan/dae 模块）。
# /media/next 挂载独立 Btrfs 数据盘。
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
