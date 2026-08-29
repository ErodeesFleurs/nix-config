# 引导配置（主机特定项：kernelParams 在各 host 中设置）
{ lib, pkgs, ... }:

{
  boot = {
    initrd.systemd.enable = true;

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
