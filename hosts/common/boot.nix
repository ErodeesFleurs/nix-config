# 引导配置（主机特定项：kernelParams 在各 host 中设置）
{ lib, pkgs, ... }:

{
  boot = {
    # systemd initrd 已是唯一路径，不再设置已移除的 initrd.systemd.enable。
    loader = {
      systemd-boot = {
        enable = true;
        # 限制 ESP 上保留的 generations 数量，避免内核镜像塞满 ESP
        configurationLimit = 8;
      };
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
}
